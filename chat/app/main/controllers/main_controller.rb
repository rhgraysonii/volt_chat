# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  model :store

  def index
  end

  def select_conversation(user)
    params._user_id = user._id
    unread_notifications_from(user).then do |results|
      results.each do |notification|
        _notifications.delete(notification)
      end
    end
    page._new_message = ''
  end
    
  def send_message
    unless page._new_message.strip.empty?
      _messages << { sender_id: Volt.user._id, receiver_id: params._user_id, text: page._new_message }
      page._new_message = ''
    end
  end

  def current_conversation
    _messages.find({ "$or" => 
                   [{ sender_id: Volt.user._id,
                      receiver_id: params._user_id },
                    { sender_id: params._user_id,
                      receiver_id: Volt.user._id }] })
  end

  def send_message
    unless page._new_message.strip.empty?
      _messages << { sender_id: Volt.user._id,
                     receiver_id: params._user_id,
                     text: page._new_message }
      _notifications << { sender_id: Volt.user._id,
                          receiver_id: params._user_id }
      page._new_message = ''
    end
  end

  def unread_notifications_from(user)
    _notifications.find({ sender_id: user._id,
                          receiver_id: Volt.user._id })
  end

  private

  def main_path
    params._controller.or('main') + '/' + params._action.or('index')
  end

  def active_tab?
    url.path.split('/')[1] == attrs.href.split('/')[1]
  end
end
