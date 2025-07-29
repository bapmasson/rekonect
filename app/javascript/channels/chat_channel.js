import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const chatMessages = document.querySelector('.chat-messages')
  const conversationId = chatMessages?.dataset.conversationId

  if (conversationId) {
    consumer.subscriptions.create(
      { channel: "ChatChannel", conversation_id: conversationId },
      {
        received(data) {
          chatMessages.insertAdjacentHTML('beforeend', data)
        }
      }
    )
  }
})
