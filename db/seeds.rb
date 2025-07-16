require 'faker'

# On nettoie d'abord la base de données pour éviter les doublons
puts "Nettoyage de la base de données..."
User.delete_all
Contact.delete_all
Relationship.delete_all
Message.delete_all
UserBadge.delete_all
Badge.delete_all
puts "Base de données nettoyée."

# Seed Users -- On va se créer chacun un compte utilisateur
prenoms = %w[Audric Barthélémy Jonathan Nour Baptiste]
noms = %w[Nomentsoa Terrier Cucculelli Harrag Masson]
usernames = %w[audricmarshall Ekenlat Laiokan u0nor bapmasson]

puts "Création des utilisateurs..."

users = prenoms.each_with_index.map do |prenom, i|
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
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
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
proximity_values = [4, 4, 3, 2, 5, 5]
puts "Création des relations..."
relation_types.each_with_index do |type, i|
  Relationship.create!(
    type: type,
    proximity: proximity_values[i]
  )
  puts "Relation #{type} (Proximité: #{proximity_values[i]}/5) créée avec succès."
end
puts "#{Relationship.count} relations créées avec succès."

# Seed Contacts
# On crée des contacts pour chaque utilisateur, en associant aléatoirement des relations (mais on va quand même leur mettre une relation Maman par défaut)

contacts = users.flat_map do |user|
  puts "Création des contacts pour l'utilisateur #{user.username}..."

  Contact.create!(
      name: "Maman",
      last_interaction_at: Faker::Date.backward(days: 1),
      notes: "Que dire de plus, c'est ma maman !",
      user: user,
      relationships: Relationship.find_by(type: 'Parent proche')
    )
  puts "Contact Maman créé pour l'utilisateur #{user.username}."

  5.times.map do
    Contact.create!(
      name: Faker::Name.name,
      last_interaction_at: Faker::Date.backward(days: 30),
      notes: Faker::Lorem.paragraph,
      user: user,
      relationships: relationships.sample
    )
  end
  puts "#{Contact.where(user: user).count} contacts créés avec succès pour l'utilisateur #{user.username}."
end

puts "#{Contact.count} contacts créés avec succès."

# Seed Messages
# On crée des messages pour chaque contact, en alternant entre des messages reçus et envoyés. On met draft: false car on veut des messages "réels" (les drafts seront les messages suggérés par l'IA).
puts "Création des conversations avec chaque contact..."
contacts.each do |contact|
  rand(1..4).times do
    Message.create!(
      content: Faker::Lorem.sentence(word_count: 10),
      draft: false,
      sent_at: Faker::Date.backward(days: 10),
      received_message: [true, false].sample,
      user: contact.user,
      contact: contact
    )
  end
  puts "Conversation entre #{contact.user.username} et #{contact.name} créée avec succès."
end

puts "#{Message.count} messages créés avec succès."

# Seed Badges
# On crée des badges pour les utilisateurs, avec des titres et descriptions aléatoires. On va en créer 5 pour commencer.
puts "Création des badges..."
badges = 5.times.map do
  Badge.create!(
    title: Faker::Games::WorldOfWarcraft.hero,
    description: Faker::Marketing.buzzwords,
    condition_description: "Complete X tasks or reach level Y"
  )
end
puts "#{Badge.count} badges créés avec succès."

# On va attribuer aléatoirement des badges à chaque utilisateur
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
