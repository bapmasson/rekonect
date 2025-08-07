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
  username: "Jonathan",
  phone_number: "+33612345678",
  address: "123 Rue de la Demo, 69006 Lyon, France",
  birth_date: Faker::Date.birthday(min_age: 25, max_age: 35),
  xp_level: 94,
  xp_points: 3499
)
puts "Utilisateur créé : #{user.username} (#{user.first_name} #{user.last_name})"


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
contact_infos = [
  { name: "Maman", notes: "C’est ma maman ❤️", relation: "Parent proche", email: "maman@test.com", photo_name: "maman.png" },
  { name: "Léo", notes: "Ami d’enfance, on se perd pas de vue !", relation: "Ami proche", email: "leo@test.com", photo_name: "leo.png" },
  { name: "Tonton Jean", notes: "Toujours présent aux repas familiaux, spécialiste des blagues beaufs.", relation: "Famille", email: "tonton.jean@test.com", photo_name: "tonton_jean.png" },
  { name: "Sarah", notes: "Amie de la fac, fan de séries et de Tellement Vrai.", relation: "Ami", email: "sarah@test.com", photo_name: "sarah.png" },
  { name: "Nour", notes: "Mon binôme sur le frontend du projet.", relation: "Collègue", email: "nour@test.com", photo_name: "nour.png" },
  { name: "Karim", notes: "Habite juste en dessous, adore discuter.", relation: "Voisin", email: "karim@test.com", photo_name: "karim.png" }
]

contact_users = {}

# Les contacts sont avant tout des users
contact_infos.each_with_index do |info, idx|
  contact_user = User.create!(
    email: info[:email], # email unique
    password: "azerty",
    first_name: info[:name].split.first,
    last_name: info[:name].split.last || info[:name],
    username: info[:name].parameterize, # username unique
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    address: Faker::Address.full_address,
    birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
    xp_level: rand(1..10),
    xp_points: rand(0..1000)
    )

  # Les contacts sont ensuite créés pour l'utilisateur principal
  contact = Contact.create!(
    name: info[:name],
    notes: info[:notes],
    user: user, # utilisateur principal
    contact_user: contact_user,
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
  puts "Contact créé : #{contact.name}, Image associée : #{contact.photo.attached? ? contact.photo.filename.to_s : 'Aucune'}"

  # création des conversations avec chaque contact
  conversation = Conversation.create!(
    contact_id: contact.id,
    user1_id: contact_user.id,
    user2_id: user.id
  )
  puts "Conversation avec #{contact.name} créée"
end

# Seed Messages
# On crée des messages pour chaque contact, en essayant de simuler des conversations réalistes et avoir des messages
# avec des réponses de l'utilisateur et des messages en attente de réponse.
# On modifie manuellement le created_at et le updated_at pour générer un historique crédible

puts "Création des messages..."
conversations = user.conversations_as_receiver
conversations.each do |conversation|

  case conversation.contact.name
  when "Maman"

    t1 = 85.days.ago
    msg1 = Message.create!(
      content: "Tu as bien dormi cette nuit ? Tu avais l’air épuisé au téléphone hier. Repose-toi bien ❤️",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    msg2 = Message.create!(
      content: "Oui, j’ai dormi comme une pierre. Merci Maman, je vais essayer de ralentir un peu cette semaine.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t1 + 2.hours,
      updated_at: t1 + 2.hours
    )

    t2 = 65.days.ago
    Message.create!(
      content: "Tu as pensé à prendre ton rendez-vous chez le dentiste ? Tu m’avais dit que ta dent te faisait mal.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t2,
      updated_at: t2
    )

    t4 = 55.days.ago
    Message.create!(
      content: "Tu sais que ça me fait de la peine quand tu ne réponds pas pendant plusieurs jours… Je m’inquiète 😔",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t4,
      updated_at: t4
    )

    Message.create!(
      content: "Désolé Maman, j’étais débordé avec le boulot. Je vais essayer d’être plus régulier, promis ❤️",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t4 + 3.hours,
      updated_at: t4 + 3.hours
    )

    t5 = 45.days.ago
    Message.create!(
      content: "J’ai repensé à Papa aujourd’hui… Tu te souviens de notre pique-nique au lac ? Il avait renversé tout le café 😂",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t5,
      updated_at: t5
    )

    Message.create!(
      content: "Oui, j’y pensais aussi. C’était une belle journée. Il nous manque.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t5 + 1.hour,
      updated_at: t5 + 1.hour
    )

    t6 = 25.days.ago
    Message.create!(
      content: "Tu m’as dit que tu avais mal au dos… Tu veux que je prenne rendez-vous chez l’ostéo pour toi ?",
      status: :sent,
      sender: user,
      receiver: conversation.user1,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t6,
      updated_at: t6
    )

    Message.create!(
      content: "Oh c’est gentil mon chéri, je vais appeler demain. C’est juste une petite douleur, rien de grave je pense.",
      status: :sent,
      contact: conversation.contact,
      sender: conversation.user1,
      receiver: user,
      conversation: conversation,
      created_at: t6 + 1.hour,
      updated_at: t6 + 1.hour
    )

    t7 = 15.days.ago
    Message.create!(
      content: "Bon anniversaire mon grand 🎉 Tu me rends fière chaque jour. J’espère que tu prends le temps de célébrer un peu 🥰",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t7,
      updated_at: t7
    )

    Message.create!(
      content: "Merci Maman ❤️ Je vais dîner avec quelques amis ce soir. Et je passe te voir demain !",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t7 + 2.hours,
      updated_at: t7 + 2.hours
    )


    t8 = 6.days.ago
    msg1 = Message.create!(
      content: "Tu as bien reçu les résultats du médecin ? J'espère que ce n'est pas trop grave. Comment tu te sens ? Je t'embrasse.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t8,
      updated_at: t8
    )

    msg2 = Message.create!(
      content: "Je suis toujours un peu fatigué, mais ça va. Le test grippal était positif donc ça devrait aller mieux dans quelques jours.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t8 + 1.hour,
      updated_at: t8 + 1.hour
    )

    t9 = 2.days.ago
    Message.create!(
      content: "Coucou fils! Alors guéri ? Tu passes dimanche à la maison ? Je fais ton plat préféré 😘",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t9,
      updated_at: t9
    )

  when "Léo"

    t1 = 35.days.ago
    Message.create!(
      content: "Tu te rappelles quand on s’était perdus dans les bois pendant le camp scout ? 😂",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    Message.create!(
      content: "Haha oui, et toi t’avais juré qu’on suivait la mousse sur les arbres… On a tourné en rond 2h !",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t1 + 1.hour,
      updated_at: t1 + 1.hour
    )

    t2 = 24.days.ago
    Message.create!(
      content: "J’ai croisé Julie au marché ce matin. Elle m’a demandé si t’étais toujours célibataire 😏",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t2,
      updated_at: t2
    )

    Message.create!(
      content: "Ah ouais ? Désolé pour elle mais tu sais bien que je suis ne suis plus dispo depuis un moment.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t2 + 2.hours,
      updated_at: t2 + 2.hours
    )

    t3 = 16.days.ago
    Message.create!(
      content: "T’as vu le match hier ? Le but de Mbappé à la 89e… j’ai hurlé dans mon salon",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t3,
      updated_at: t3
    )

    Message.create!(
      content: "Incroyable ! On se fait une soirée Ligue des Champions chez moi la semaine prochaine ?",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t3 + 1.hour,
      updated_at: t3 + 1.hour
    )

    t4 = 5.days.ago
    msg = Message.create!(
      content: "Tu viens au foot ce soir ? L’équipe est presque complète.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t4,
      updated_at: t4
    )
    msg2 = Message.create!(
      content: "Bien sûr, je ramène les maillots !",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t4 + 1.hour,
      updated_at: t4 + 1.hour
    )


  when "Tonton Jean"

    t1 = 5.months.ago
    Message.create!(
      content: "Je passe à Lyon le mois prochain, si t’es dispo on peut se faire un resto. Je t’invite, mais tu choisis pas le plus cher hein 😜",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    t2 = 3.months.ago
    msg = Message.create!(
      content: "Tu connais la différence entre un steak et un slip ? Y’en a pas, c’est dans les deux qu’on met la viande !",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t2,
      updated_at: t2
    )
    msg2 = Message.create!(
      content: "Tonton Jean, tu n'as pas des amis à qui raconter tes blagues ?",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t2 + 12.days,
      updated_at: t2 + 12.days
    )

  when "Sarah"

    t1 = 70.days.ago
    Message.create!(
      content: "Je suis tombée sur une playlist ‘Tristesse productive’… Tu crois que c’est censé m’aider à bosser ou à pleurer ?",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    Message.create!(
      content: "Les deux. C’est le concept du millénaire : souffrir en silence mais avec du style.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t1 + 2.hours,
      updated_at: t1 + 2.hours
    )

    t2 = 48.days.ago
    Message.create!(
      content: "Tu te souviens du mec chelou au vernissage ? Celui qui parlait aux tableaux comme si c’était ses ex ?",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t2,
      updated_at: t2
    )

    t3 = rand(2..5).days.ago
    msg = Message.create!(
      content: "Tellement Vrai a sorti un épisode sur les gens qui parlent à leurs plantes 😭",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t3,
      updated_at: t3
    )
    msg2 = Message.create!(
      content: "J’ai vu ! J’ai failli m’y reconnaître haha",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t3 + 1.day,
      updated_at: t3 + 1.day
    )

  when "Nour"

    t1 = 17.days.ago
    Message.create!(
      content: "Le café maison c’est mieux que celui du bureau, mais j’avoue qu’il me manque les potins de la machine 😅",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    Message.create!(
      content: "Grave. Maintenant je fais mes pauses café avec mon chat, mais il est nul en gossip.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t1 + 2.hours,
      updated_at: t1 + 2.hours
    )

    t2 = 13.days.ago
    Message.create!(
      content: "Tu as vu on est dans la même équipe pour le nouveau projet ! Ça va être sympa de bosser ensemble.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t2,
      updated_at: t2
    )

    Message.create!(
      content: "Oui j'ai vu ! On va pouvoir faire des merveilles. Hâte de démarrer !",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t2 + 1.hour,
      updated_at: t2 + 1.hour
    )

    t3 = rand(2..4).days.ago
    msg = Message.create!(
      content: "Ton Figma il est vraiment stylé ! J'ai fait une PR pour le projet, tu peux la regarder ?",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t3,
      updated_at: t3
    )
    msg2 = Message.create!(
      content: "Merci 🤗 Je suis dessus, je merge ça dans 10 min 🚀",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t3 + 2.hours,
      updated_at: t3 + 2.hours
    )

    t4 = 1.day.ago
    Message.create!(
      content: "T'as mis à jour le design du dashboard ? J'ai pas trouvé la dernière version.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t4,
      updated_at: t4
    )

  when "Karim"

    t1 = rand(3..4).months.ago
    Message.create!(
      content: "Salut ! Juste pour te dire que ton colis est chez moi, le livreur s’est encore trompé d’étage.",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t1,
      updated_at: t1
    )

    Message.create!(
      content: "Ah merci beaucoup ! Je passe le récupérer dans la soirée si ça te va.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t1 + 2.hours,
      updated_at: t1 + 2.hours
    )

    t = rand(2..4).weeks.ago
    msg = Message.create!(
      content: "Dis donc, t’aurais pas un tournevis plat à me prêter ?",
      status: :sent,
      sender: conversation.user1,
      receiver: user,
      contact: conversation.contact,
      conversation: conversation,
      created_at: t,
      updated_at: t
    )
    msg2 = Message.create!(
      content: "J’en ai un ! Je te le descends tout à l’heure.",
      status: :sent,
      contact: conversation.contact,
      sender: user,
      receiver: conversation.user1,
      conversation: conversation,
      created_at: t + 1.day,
      updated_at: t + 1.day
    )
  end

  puts "Conversation avec #{conversation.contact.name} enregistrée avec succès."
end

puts "#{Message.count} messages créés avec succès."

# Seed Badges
# On crée des badges pour les utilisateurs, avec des titres et descriptions aléatoires. On va en créer 5 pour commencer.
puts "Création des badges..."

badges_infos = [
  { title: "Répondeur Express", description: "Toujours prêt à dégainer une réponse.", condition_description: "Répondre à 10 messages en moins de 5 minutes", photo_name: "badge_repondeur.png" },
  { title: "Relanceur Pro", description: "Relancer les conversations comme un vrai stratège.", condition_description: "Relancer 15 conversations restées sans réponse pendant plus de 24h", photo_name: "badge_relanceur.png" },
  { title: "Rekonecteur Débutant", description: "Constante et réactivité sont les clés de la connexion.", condition_description: "Atteindre le niveau 10 dans l’application", photo_name: "badge_rekonecteur_debutant.png" },
  { title: "Rekonecteur Confirmé", description: "Maître dans l’art de la connexion.", condition_description: "Atteindre le niveau 20 dans l’application", photo_name: "badge_rekonecteur_confirme.png" }
]

badges_infos.each do |info|
  badge = Badge.create!(
    title: info[:title],
    description: info[:description],
    condition_description: info[:condition_description]
  )

  if info[:photo_name].present?
    badge.image.attach(io: File.open(Rails.root.join("app/assets/images/#{info[:photo_name]}")), filename: info[:photo_name], content_type: 'image/png')
    puts "Image attachée pour #{badge.title} : #{info[:photo_name]}"
  else
    # Si aucune photo spécifique n'est définie, tu peux choisir d'attacher une image par défaut ici
    badge.image.attach(io: File.open(Rails.root.join("app/assets/images/badge.png")), filename: 'badge.png', content_type: 'image/png')
    puts "Image par défaut attachée pour #{badge.title}."
  end
  puts "Badge #{badge.title} créé avec succès."
end

puts "#{Badge.count} badges créés avec succès."
# On va attribuer aléatoirement des badges à chaque utilisateur
badges = Badge.all

# On attribue les badges à l'utilisateur principal pour la démo
badges.each do |badge|
  UserBadge.create!(
    user: user,
    badge: badge,
    obtained_at: Faker::Date.backward(days: 100)
  )
  puts "Badge '#{badge.title}' attribué à #{user.username}."
end

puts "#{UserBadge.count} badges attribués avec succès."

puts "Seed terminé avec succès !"
puts "Base de données prête à l'emploi !"
puts "Ne pas hésiter à modifier les seeds.rb pour ajouter plus de données ou adapter les existantes aux validations que nous ajouterons."
