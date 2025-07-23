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

# ------------------------------SEED USERS DEMO---------------------------------
# On crée un utilisateur principal pour la démo, avec des données réalistes
puts "Création de l'utilisateur principal..."
user = User.create!(
  email: "jonathan@test.com",
  password: "azerty",
  first_name: "Jonathan",
  last_name: "Cuculelli",
  username: "Laiokan",
  phone_number: "+33612345678",
  address: "123 Rue de la Demo, 69006 Lyon, France",
  birth_date: Faker::Date.birthday(min_age: 25, max_age: 35),
  xp_level: 94
)
puts "Utilisateur créé : #{user.username} (#{user.first_name} #{user.last_name})"

# # Seed Users -- On va se créer chacun un compte utilisateur
# prenoms = %w[Audric Barthélémy Jonathan Nour Baptiste]
# noms = %w[Nomentsoa Terrier Cucculelli Harrag Masson]
# usernames = %w[audricmarshall Ekenlat Laiokan u0nor bapmasson]

# puts "Création des utilisateurs..."
# prenoms.each_with_index.map do |prenom, i|
#   User.create!(
#     # chaque utilisateur a un email unique basé sur son prénom en minuscule sans accents
#     email: "#{prenom.parameterize}@test.com",
#     # mot de passe par défaut pour tous les utilisateurs
#     password: "azerty",
#     first_name: prenom,
#     last_name: noms[i],
#     username: usernames[i],
#     # A partir de là on utilise Faker pour générer des données aléatoires
#     phone_number: Faker::PhoneNumber.cell_phone_in_e164,
#     address: Faker::Address.full_address,
#     birth_date: Faker::Date.birthday(min_age: 18, max_age: 35),
#     # On part avec déjà de l'expérience car on est des boss
#     xp_level: rand(1..100)
#   )
#   puts "Utilisateur créé : #{usernames[i]} (#{prenom} #{noms[i]})"
# end

# puts "#{User.count} utilisateurs créés avec succès."


# Seed Relationships
# On crée des types de relations (qu'on pourra modifier selon nos validations) avec des proximités différentes notées de 1 à 10
# 1 étant le plus éloigné et 10 le plus proche

relations_type = {
  "Parent proche" => 10,
  "Ami proche" => 9,
  "Famille" => 8,
  "Ami" => 7,
  "Collègue" => 5,
  "Voisin" => 3
}

puts "Création des relations..."
relations_type.each do |type, proximity|
  Relationship.create!(
    relation_type: type,
    proximity: proximity
  )
  puts "Relation #{type} (Proximité: #{proximity}/10) créée avec succès."
end
puts "#{Relationship.count} relations créées avec succès."

# ----------------------------SEED CONTACTS DEMO--------------------------------
# On crée des contacts pour l'utilisateur principal, avec des données réalistes
puts "Création des contacts..."
contact_data = [
  { name: "Maman", notes: "C’est ma maman ❤️", relation: "Parent proche" },
  { name: "Léo", notes: "Ami d’enfance, on se perd pas de vue !", relation: "Ami proche" },
  { name: "Tonton Jean", notes: "Toujours présent aux repas familiaux, spécialiste des blagues beaufs.", relation: "Famille" },
  { name: "Sarah", notes: "Amie de la fac, fan de séries et de Tellement Vrai.", relation: "Ami" },
  { name: "Nour", notes: "Mon binôme sur le frontend du projet.", relation: "Collègue" },
  { name: "Karim", notes: "Habite juste en dessous, adore discuter.", relation: "Voisin" }
]
contact_data.each do |data|
  Contact.create!(
    name: data[:name],
    notes: data[:notes],
    user: user,
    relationship: Relationship.find_by(relation_type: data[:relation])
  )
  puts "Contact #{data[:name]} créé avec succès."
end
puts "#{Contact.count} contacts créés."

# Seed Contacts
# On crée des contacts pour chaque utilisateur, en associant aléatoirement des relations (mais on va quand même leur mettre une relation Maman par défaut)
# users = User.all
# relationships = Relationship.all
# users.flat_map do |user|
#   puts "Création des contacts pour l'utilisateur #{user.username}..."

#   # On crée une Maman pour tout le monde
#   Contact.create!(
#       name: "Maman",
#       notes: "Que dire de plus, c'est ma maman !",
#       user: user,
#       relationship: Relationship.find_by(relation_type: 'Parent proche')
#     )
#   puts "Contact Maman créé pour l'utilisateur #{user.username}."

#   # Et 5 contacts aléatoires
#   5.times.map do
#     Contact.create!(
#       name: Faker::Name.name,
#       notes: Faker::Lorem.paragraph_by_chars(number: 500),
#       user: user,
#       relationship: relationships.sample
#     )
#   end
#   puts "#{Contact.where(user: user).count} contacts créés avec succès pour l'utilisateur #{user.username}."
# end

# puts "#{Contact.count} contacts créés avec succès."

# ----------------------------SEED MESSAGES DEMO--------------------------------
# On crée des messages pour chaque contact, en essayant de simuler des conversations réalistes et avoir des messages
# avec des réponses de l'utilisateur et des messages en attente de réponse.
# On modifie manuellement le created_at et le updated_at pour générer un historique crédible

puts "Création des messages..."

contacts = Contact.all
contacts.each do |contact|
  case contact.name
  when "Maman"
    # Conversation en plusieurs étapes, dernier message reçu sans réponse
    t1 = 6.days.ago
    msg1 = Message.create!(
      content: "Tu as bien reçu les résultats du médecin ? J'espère que ce n'est pas trop grave. Comment tu te sens ?",
      status: :received,
      user: user,
      contact: contact,
      created_at: t1,
      updated_at: t1
    )
    msg1.update_columns(
      user_answer: "Je suis toujours un peu fatigué, mais ça va. Le test grippal était positif donc ça devrait aller mieux dans quelques jours.",
      status: :sent,
      sent_at: t1 + 1.hour,
      updated_at: t1 + 1.hour
    )

    t2 = 2.days.ago
    Message.create!(
      content: "Coucou fils! Alors guéri ? Tu passes dimanche à la maison ? Je fais ton plat préféré 😘",
      status: :received,
      user: user,
      contact: contact,
      created_at: t2,
      updated_at: t2
    )

  when "Léo"
    t = rand(3..7).days.ago
    msg = Message.create!(
      content: "Tu viens au foot ce soir ? L’équipe est presque complète.",
      status: :received,
      user: user,
      contact: contact,
      created_at: t,
      updated_at: t
    )
    msg.update_columns(
      user_answer: "Bien sûr, je ramène les maillots !",
      status: :sent,
      sent_at: t + 1.hour,
      updated_at: t + 1.hour
    )

  when "Tonton Jean"
    t = rand(3..6).months.ago
    msg = Message.create!(
      content: "Tu connais la différence entre un steak et un slip ? Y’en a pas, c’est dans les deux qu’on met la viande !",
      status: :received,
      user: user,
      contact: contact,
      created_at: t,
      updated_at: t
    )
    msg.update_columns(
      user_answer: "Tonton Jean, tu n'as pas des amis à qui raconter tes blagues ?",
      status: :sent,
      sent_at: t + 12.days,
      updated_at: t + 12.days
    )

  when "Sarah"
    t = rand(2..5).days.ago
    msg = Message.create!(
      content: "Tellement Vrai a sorti un épisode sur les gens qui parlent à leurs plantes 😭",
      status: :received,
      user: user,
      contact: contact,
      created_at: t,
      updated_at: t
    )
    msg.update_columns(
      user_answer: "J’ai vu ! J’ai failli m’y reconnaître haha",
      status: :sent,
      sent_at: t + 1.day,
      updated_at: t + 1.day
    )

  when "Nour"
    t = rand(2..4).days.ago
    msg = Message.create!(
      content: "Ton Figma il est vraiment stylé ! J'ai fait une PR pour le projet, tu peux la regarder ?",
      status: :received,
      user: user,
      contact: contact,
      created_at: t,
      updated_at: t
    )
    msg.update_columns(
      user_answer: "Merci 🤗 Je suis dessus, je merge ça dans 10 min 🚀",
      status: :sent,
      sent_at: t + 2.hours,
      updated_at: t + 2.hours
    )

    # Un message reçu sans réponse pour actualiser le dashboard quand on aura répondu à Maman dans la démo
    t2 = 1.day.ago
    Message.create!(
      content: "T'as mis à jour le design du dashboard ? J'ai pas trouvé la dernière version.",
      status: :received,
      user: user,
      contact: contact,
      created_at: t2,
      updated_at: t2
    )

  when "Karim"
    t = rand(2..6).weeks.ago
    msg = Message.create!(
      content: "Dis donc, t’aurais pas un tournevis plat à me prêter ?",
      status: :received,
      user: user,
      contact: contact,
      created_at: t,
      updated_at: t
    )
    msg.update_columns(
      user_answer: "J’en ai un ! Je te le descends tout à l’heure.",
      status: :sent,
      sent_at: t + 1.day,
      updated_at: t + 1.day
    )
  end

  puts "Conversation avec #{contact.name} enregistrée avec succès."
end

puts "#{Message.count} messages créés avec succès."


# Seed Messages
# On crée des messages pour chaque contact, en leur créant un message qui a eu une réponse, et un message en attente de réponse. On ajoute éventuellement un message avec une suggestion IA mais on l'enlèvera quand on aura implanté l'IA dans le projet
# THIRD_MESSAGE_PROBABILITY = 0.5

# contacts = Contact.all
# puts "Création des conversations avec chaque contact..."
# contacts.each do |contact|
#   # Message complet : message du contact + suggestion IA + réponse utilisateur
#   message1 = Message.create!(
#     content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :received,
#     user: contact.user,
#     contact: contact
#   )
#   message1.update!(
#     ai_draft: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :draft_by_ai
#   )
#   message1.update!(
#     user_answer: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :sent,
#     sent_at: Faker::Date.backward(days: 3)
#   )

#   # Message sans réponse utilisateur
#   message2 = Message.create!(
#       content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#       status: :received,
#       user: contact.user,
#       contact: contact
#     )

#   # Occasionnellement, message avec suggestion IA mais pas de réponse utilisateur

#   if rand < THIRD_MESSAGE_PROBABILITY
#   message3 = Message.create!(
#     content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :received,
#     user: contact.user,
#     contact: contact
#   )
#   message3.update!(
#     ai_draft: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :draft_by_ai
#   )
#   end
#   puts "Conversation entre #{contact.user.username} et #{contact.name} créée avec succès."
# end


# puts "#{Message.count} messages créés avec succès."

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

# On attribue 2 badges aléatoires à l'utilisateur principal pour la démo
badges.sample(2).each do |badge|
  UserBadge.create!(
    user: user,
    badge: badge,
    obtained_at: Faker::Date.backward(days: 100)
  )
  puts "Badge '#{badge.title}' attribué à #{user.username}."
end

# users.each do |user|
#   badges.sample(2).each do |badge|
#     UserBadge.create!(
#       user: user,
#       badge: badge,
#       obtained_at: Faker::Date.backward(days: 100)
#     )
#     puts "Badge '#{badge.title}' attribué à #{user.username}."
#   end
# end

puts "#{UserBadge.count} badges attribués avec succès."

puts "Seed terminé avec succès !"
puts "Base de données prête à l'emploi !"
puts "Ne pas hésiter à modifier les seeds.rb pour ajouter plus de données ou adapter les existantes aux validations que nous ajouterons."
