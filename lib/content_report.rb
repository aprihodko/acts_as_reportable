class ContentReport < ActiveRecord::Base
  belongs_to :reportable, :polymorphic => true
  
  # NOTE: Content reports belong to a fan
  belongs_to :fan
  
  def self.content_report_types
    [["Spam","0"], ["Duplicate","1"], ["Inappropriate","2"], ["Offensive","3"], ["Pornography", "4"]]
  end  
   
  # Helper class method to lookup all content reports assigned
  # to all reportable types for a given fan.
  def self.find_content_reports_by_fan(fan)
    find(:all,
      :conditions => ["fan_id = ?", fan.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all content reports for 
  # reportable class name and reportable id.
  def self.find_content_reports_for_reportable(reportable_str, reportable_id)
    find(:all,
      :conditions => ["reportable_type = ? and reportable_id = ?", reportable_str, reportable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a reportable object
  # given the reportable class name and id 
  def self.find_reportable(reportable_str, reportable_id)
    reportable_str.constantize.find(reportable_id)
  end
end