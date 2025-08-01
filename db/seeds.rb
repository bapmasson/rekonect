require 'faker'

# On nettoie d'abord la base de données pour éviter les doublons
# NE PAS MODIFIER L'ORDRE DES LIGNES DE DESTRUCTION CAR LES DEPENDANCES ENTRE MODELES FONT PLANTER LA SEED SI CET ORDRE N'EST PAS BON
puts "Nettoyage de la base de données..."
Message.destroy_all
Conversation.destroy_all
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
  last_name: "Cucculelli",
  username: "Laiokan",
  phone_number: "+33612345678",
  address: "123 Rue de la Demo, 69006 Lyon, France",
  birth_date: Faker::Date.birthday(min_age: 25, max_age: 35),
  xp_level: 94,
  xp_points: 3499
)
puts "Utilisateur créé : #{user.username} (#{user.first_name} #{user.last_name}"

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


# 2. Création des contacts comme users
contact_infos = [
  { name: "Maman", notes: "C’est ma maman ❤️", relation: "Parent proche", email: "maman@test.com" },
  { name: "Léo", notes: "Ami d’enfance, on se perd pas de vue !", relation: "Ami proche", email: "leo@test.com" },
  { name: "Tonton Jean", notes: "Toujours présent aux repas familiaux, spécialiste des blagues beaufs.", relation: "Famille", email: "tonton.jean@test.com" },
  { name: "Sarah", notes: "Amie de la fac, fan de séries et de Tellement Vrai.", relation: "Ami", email: "sarah@test.com" },
  { name: "Nour", notes: "Mon binôme sur le frontend du projet.", relation: "Collègue", email: "nour@test.com" },
  { name: "Karim", notes: "Habite juste en dessous, adore discuter.", relation: "Voisin", email: "karim@test.com" }
]

contact_users = {}

contact_infos.each_with_index do |info, idx|
  contact_user = User.create!(
    email: "#{info[:email].split('@').first}-contact-#{idx}@test.com", # email unique
    password: "azerty",
    first_name: info[:name].split.first,
    last_name: info[:name].split.last || info[:name],
    username: "#{info[:name].parameterize}-contact-#{idx}"[0, 20], # username unique
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    address: Faker::Address.full_address,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
    xp_level: rand(1..10),
    xp_points: rand(0..1000)
  )
  contact_users[info[:name]] = contact_user
end

# 3. Création des contacts pour le compte principal
contacts = []
contact_infos.each do |info|
  contact = Contact.create!(
    name: info[:name],
    notes: info[:notes],
    user: user, # utilisateur principal
    contact_user: contact_users[info[:name]],
    relationship: Relationship.find_by(relation_type: info[:relation])
  )
    if info[:photo_name].present?
    contact.photo.attach(io: File.open(Rails.root.join("app/assets/images/#{info[:photo_name]}")), filename: info[:photo_name], content_type: 'image/png')
    puts "Image attachée pour #{contact.name} : #{info[:photo_name]}"
  else
    # Si aucune photo spécifique n'est définie, tu peux choisir d'attacher une image par défaut ici
    contact.photo.attach(io: File.open(Rails.root.join("app/assets/images/default-avatar.png")), filename: 'default-avatar.png', content_type: 'image/png')
    puts "Image par défaut attachée pour #{contact.name}"
  end
  contacts << contact
  puts "Contact créé : #{contact.name}, Image associée : #{contact.photo.attached? ? contact.photo.filename.to_s : 'Aucune'}"
end

# 4. Chaque contact devient aussi contact des autres contacts
contact_users.values.each do |contact_user|
  contact_infos.each do |info|
    next if contact_user.email == info[:email]
    Contact.create!(
      name: info[:name],
      notes: info[:notes],
      user: contact_user,
      contact_user: contact_users[info[:name]],
      relationship: Relationship.find_by(relation_type: info[:relation])
    )
  end
end

# Ajoute Jonathan comme contact pour chaque contact user
contact_users.values.each do |contact_user|
  Contact.create!(
    name: user.first_name,
    notes: "Utilisateur principal",
    user: contact_user,
    contact_user: user,
    relationship: Relationship.find_by(relation_type: "Ami proche")
  )
end

# Crée la conversation et un message du point de vue de chaque contact user vers Jonathan
contact_users.values.each do |contact_user|
  contact = Contact.find_by(user: contact_user, contact_user: user)
  next unless contact
  conversation = Conversation.find_or_create_by!(
    contact_id: contact.id,
    user1_id: contact_user.id,
    user2_id: user.id
  )
  # Message.create!(
  #   content: "Salut Jonathan, c'est #{contact_user.first_name} !",
  #   status: :sent,
  #   sender_id: contact_user.id,
  #   receiver_id: user.id,
  #   user_id: contact_user.id,
  #   contact: contact,
  #   conversation_id: conversation.id,
  #   created_at: 1.day.ago,
  #   updated_at: 1.day.ago
  # )
end

# Crée toutes les conversations et messages entre tous les users
all_users = [user] + contact_users.values

all_users.combination(2).each do |user_a, user_b|
  # Contact de user_a vers user_b
  contact_a = Contact.find_or_create_by!(
    user: user_a,
    contact_user: user_b
  )
  conversation_a = Conversation.find_or_create_by!(
    contact_id: contact_a.id,
    user1_id: user_a.id,
    user2_id: user_b.id
  )
  # Message.create!(
  #   content: "Salut #{user_b.first_name}, c'est #{user_a.first_name} !",
  #   status: :sent,
  #   sender_id: user_a.id,
  #   receiver_id: user_b.id,
  #   user_id: user_a.id,
  #   contact: contact_a,
  #   conversation_id: conversation_a.id,
  #   created_at: 1.year.ago,
  #   updated_at: 1.year.ago
  # )

  # Contact de user_b vers user_a
  contact_b = Contact.find_or_create_by!(
    user: user_b,
    contact_user: user_a
  )
  conversation_b = Conversation.find_or_create_by!(
    contact_id: contact_b.id,
    user1_id: user_b.id,
    user2_id: user_a.id
  )
  # Message.create!(
  #   content: "Salut #{user_a.first_name}, c'est #{user_b.first_name} !",
  #   status: :sent,
  #   sender_id: user_b.id,
  #   receiver_id: user_a.id,
  #   user_id: user_b.id,
  #   contact: contact_b,
  #   conversation_id: conversation_b.id,
  #   created_at: 1.year.ago,
  #   updated_at: 1.year.ago
  # )
end

# Seed Messages
# On crée des messages pour chaque contact, en essayant de simuler des conversations réalistes et avoir des messages
# avec des réponses de l'utilisateur et des messages en attente de réponse.
# On modifie manuellement le created_at et le updated_at pour générer un historique crédible

puts "Création des messages..."
contacts = Contact.all
contacts.each do |contact|
  contact_user = contact.contact_user

  # Trouve ou crée la conversation entre l'utilisateur principal et le contact cible
  conversation = Conversation.find_or_create_by!(
    contact_id: contact.id,
    user1_id: user.id,
    user2_id: contact_user.id
  )

  case contact.name
  when "Maman"
    t1 = 6.days.ago
    msg1 = Message.create!(
      content: "Tu as bien reçu les résultats du médecin ? J'espère que ce n'est pas trop grave. Comment tu te sens ?",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t1,
      updated_at: t1
    )

    msg2 = Message.create!(
      content: "Je suis toujours un peu fatigué, mais ça va. Le test grippal était positif donc ça devrait aller mieux dans quelques jours.",
      status: :sent,
      contact: contact,
      sender_id: user.id,
      receiver_id: contact_user.id,
      user_id: user.id,
      sent_at: t1 + 1.hour,
      conversation_id: conversation.id,
      created_at: t1 + 1.hour,
      updated_at: t1 + 1.hour
    )

    t2 = 2.days.ago
    Message.create!(
      content: "Coucou fils! Alors guéri ? Tu passes dimanche à la maison ? Je fais ton plat préféré 😘",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t2,
      updated_at: t2
    )

  when "Léo"
    t = rand(3..7).days.ago
    msg = Message.create!(
      content: "Tu viens au foot ce soir ? L’équipe est presque complète.",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "Bien sûr, je ramène les maillots !",
      status: :sent,
      sender_id: user.id,
      receiver_id: contact_user.id,
      contact: contact,
      user_id: user.id,
      sent_at: t + 1.hour,
      conversation_id: conversation.id,
      created_at: t + 1.hour,
      updated_at: t + 1.hour
    )


  when "Tonton Jean"
    t = rand(3..6).months.ago
    msg = Message.create!(
      content: "Tu connais la différence entre un steak et un slip ? Y’en a pas, c’est dans les deux qu’on met la viande !",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "Tonton Jean, tu n'as pas des amis à qui raconter tes blagues ?",
      status: :sent,
      contact: contact,
      sender_id: user.id,
      receiver_id: contact_user.id,
      user_id: user.id,
      sent_at: t + 12.days,
      conversation_id: conversation.id,
      created_at: t + 12.days,
      updated_at: t + 12.days
    )

  when "Sarah"
    t = rand(2..5).days.ago
    msg = Message.create!(
      content: "Tellement Vrai a sorti un épisode sur les gens qui parlent à leurs plantes 😭",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "J’ai vu ! J’ai failli m’y reconnaître haha",
      status: :sent,
      sender_id: user.id,
      contact: contact,
      receiver_id: contact_user.id,
      user_id: user.id,
      sent_at: t + 1.day,
      conversation_id: conversation.id,
      created_at: t + 1.day,
      updated_at: t + 1.day
    )

  when "Nour"
    t = rand(2..4).days.ago
    msg = Message.create!(
      content: "Ton Figma il est vraiment stylé ! J'ai fait une PR pour le projet, tu peux la regarder ?",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "Merci 🤗 Je suis dessus, je merge ça dans 10 min 🚀",
      status: :sent,
      sender_id: user.id,
      contact: contact,
      receiver_id: contact_user.id,
      user_id: user.id,
      sent_at: t + 2.hours,
      conversation_id: conversation.id,
      created_at: t + 2.hours,
      updated_at: t + 2.hours
    )

    t2 = 1.day.ago
    Message.create!(
      content: "T'as mis à jour le design du dashboard ? J'ai pas trouvé la dernière version.",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t2,
      updated_at: t2
    )

  when "Karim"
    t = rand(2..6).weeks.ago
    msg = Message.create!(
      content: "Dis donc, t’aurais pas un tournevis plat à me prêter ?",
      status: :sent,
      sender_id: contact_user.id,
      receiver_id: user.id,
      user_id: contact_user.id,
      contact: contact,
      conversation_id: conversation.id,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "J’en ai un ! Je te le descends tout à l’heure.",
      status: :sent,
      sender_id: user.id,
      receiver_id: contact_user.id,
      contact: contact,
      user_id: user.id,
      sent_at: t + 1.day,
      conversation_id: conversation.id,
      created_at: t + 1.day,
      updated_at: t + 1.day
    )
    msg.update_column(:updated_at, t + 1.day)
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
#     status: :sent,
#     user: contact.user,
#     contact: contact
#   )
#   message1.update!(
#     ai_draft: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :draft_by_ai
#   )
#   message1.update!(
#     content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#     status: :sent,
#     sent_at: Faker::Date.backward(days: 3)
#   )

#   # Message sans réponse utilisateur
#   message2 = Message.create!(
#       content: Faker::Lorem.sentence(word_count: 6, supplemental: true, random_words_to_add: 6),
#       status: :sent,
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
