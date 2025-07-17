require 'faker'

# On nettoie d'abord la base de données pour éviter les doublons
# NE PAS MODIFIER L'ORDRE DES LIGNES DE DESTRUCTION CAR LES DEPENDANCES ENTRE MODELES FONT PLANTER LA SEED SI CET ORDRE N'EST PAS BON
puts "Nettoyage de la base de données..."
Message.destroy_all
Contact.destroy_all
Relationship.destroy_all
UserBadge.destroy_all
User.destroy_all
Badge.destroy_all
puts "Base de données nettoyée."

# Seed Users -- On va se créer chacun un compte utilisateur
prenoms = %w[Audric Barthélémy Jonathan Nour Baptiste]
noms = %w[Nomentsoa Terrier Cucculelli Harrag Masson]
usernames = %w[audricmarshall Ekenlat Laiokan u0nor bapmasson]

puts "Création des utilisateurs..."

prenoms.each_with_index.map do |prenom, i|
  User.create!(
    # chaque utilisateur a un email unique basé sur son prénom en minuscule sans accents
    email: "#{prenom.parameterize}@test.com",
    # mot de passe par défaut pour tous les utilisateurs
    password: "azerty",
    first_name: prenom,
    last_name: noms[i],
    username: usernames[i],
    # A partir de là on utilise Faker pour générer des données aléatoires
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    address: Faker::Address.full_address,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 35),
    # On part avec déjà de l'expérience car on est des boss
    xp_level: rand(1..100)
  )
  puts "Utilisateur créé : #{usernames[i]} (#{prenom} #{noms[i]})"
end

puts "#{User.count} utilisateurs créés avec succès."


# Seed Relationships
# On crée des types de relations (qu'on pourra modifier selon nos validations) avec des proximités différentes notées de 1 à 5
# 1 étant le plus éloigné et 5 le plus proche
relation_types = %w[Famille Ami Collègue Voisin Ami\ proche Parent\ proche]
proximity_values = [8, 7, 5, 3, 9, 10]
puts "Création des relations..."
relation_types.each_with_index do |type, i|
  Relationship.create!(
    relation_type: type,
    proximity: proximity_values[i]
  )
  puts "Relation #{type} (Proximité: #{proximity_values[i]}/10) créée avec succès."
end
puts "#{Relationship.count} relations créées avec succès."

# Seed Contacts
# On crée des contacts pour chaque utilisateur, en associant aléatoirement des relations (mais on va quand même leur mettre une relation Maman par défaut)
users = User.all
relationships = Relationship.all
users.flat_map do |user|
  puts "Création des contacts pour l'utilisateur #{user.username}..."

  # On crée une Maman pour tout le monde
  Contact.create!(
      name: "Maman",
      notes: "Que dire de plus, c'est ma maman !",
      user: user,
      relationship: Relationship.find_by(relation_type: 'Parent proche')
    )
  puts "Contact Maman créé pour l'utilisateur #{user.username}."

  # Et 5 contacts aléatoires
  5.times.map do
    Contact.create!(
      name: Faker::Name.name,
      notes: Faker::Lorem.paragraph_by_chars(number: 500),
      user: user,
      relationship: relationships.sample
    )
  end
  puts "#{Contact.where(user: user).count} contacts créés avec succès pour l'utilisateur #{user.username}."
end

puts "#{Contact.count} contacts créés avec succès."

# Seed Messages
# On crée des messages pour chaque contact, en leur créant un message qui a eu une réponse, et un message en attente de réponse. On ajoute éventuellement un message avec une suggestion IA mais on l'enlèvera quand on aura implanté l'IA dans le projet
THIRD_MESSAGE_PROBABILITY = 0.5

contacts = Contact.all
puts "Création des conversations avec chaque contact..."
contacts.each do |contact|
  # Message complet : message du contact + suggestion IA + réponse utilisateur
  message1 = Message.create!(
    content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
    status: :received,
    user: contact.user,
    contact: contact
  )
  message1.update!(
    ai_draft: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
    status: :draft_by_ai
  )
  message1.update!(
    user_answer: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
    status: :sent,
    sent_at: Faker::Date.backward(days: 3)
  )

  # Message sans réponse utilisateur
  message2 = Message.create!(
      content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
      status: :received,
      user: contact.user,
      contact: contact
    )

  # Occasionnellement, message avec suggestion IA mais pas de réponse utilisateur

  if rand < THIRD_MESSAGE_PROBABILITY
  message3 = Message.create!(
    content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
    status: :received,
    user: contact.user,
    contact: contact
  )
  message3.update!(
    ai_draft: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
    status: :draft_by_ai
  )
  end
  puts "Conversation entre #{contact.user.username} et #{contact.name} créée avec succès."
end


puts "#{Message.count} messages créés avec succès."

# Seed Badges
# On crée des badges pour les utilisateurs, avec des titres et descriptions aléatoires. On va en créer 5 pour commencer.
puts "Création des badges..."
5.times.map do
  Badge.create!(
    title: Faker::Superhero.name,
    description: Faker::Marketing.buzzwords,
    condition_description: "Complete X tasks or reach level Y"
  )
end
puts "#{Badge.count} badges créés avec succès."

# On va attribuer aléatoirement des badges à chaque utilisateur
badges = Badge.all
users.each do |user|
  badges.sample(2).each do |badge|
    UserBadge.create!(
      user: user,
      badge: badge,
      obtained_at: Faker::Date.backward(days: 100)
    )
    puts "Badge '#{badge.title}' attribué à #{user.username}."
  end
end

puts "#{UserBadge.count} badges attribués avec succès."

puts "Seed terminé avec succès !"
puts "Base de données prête à l'emploi !"
puts "Ne pas hésiter à modifier les seeds.rb pour ajouter plus de données ou adapter les existantes aux validations que nous ajouterons."
