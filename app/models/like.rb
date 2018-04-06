class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  after_create :add_points, :feed_release
  
  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_notification_feed(self.likeable.id)]
  end

  def activity_object
    self.likeable
  end

  private

    def add_points
      self.user.change_points( 100 )
    end

    def feed_release
      if self.likeable_type == "Comment"
        comment = self.likeable
        feed = StreamRails.feed_manager.get_feed( 'release', comment.commentable_id )
        activity = create_activity
        activity[:actor] = "Release:#{self.likeable_id}"
        activity[:object] = "User:#{self.user_id}"
        feed.add_activity(activity)
      end
    end
end
