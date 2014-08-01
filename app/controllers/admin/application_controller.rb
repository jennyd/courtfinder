require 'iron_mq'

class Admin::ApplicationController < ::ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  def purge_all_pages
    # Placeholder for feature functionality
  end

  def publish_changes(court)
    @court_to_be_serialised = {
      :alert => court.alert ? sanitize(court.alert) : nil,
      :court_number => court.court_number,
      :latitude => court.latitude,
      :longitude => court.longitude,
      :name => sanitize(court.name),
      :slug => court.slug,
      :area => sanitize(court.area.name),
      :addresses => court.addresses.map do |address|
        {
          :type => address.address_type.name,
          :address_line_1 => sanitize(address.address_line_1),
          :address_line_2 => sanitize(address.address_line_2),
          :address_line_3 => sanitize(address.address_line_3),
          :address_line_4 => sanitize(address.address_line_4),
          :postcode => sanitize(address.postcode),
          :town => address.town ? sanitize(address.town.name) : nil,
          :county => (address.town and address.town.county) ? sanitize(address.town.county.name) : nil
        }
      end,
      :opening_times => court.opening_times.map do |opening_time|
        opening_time.opening_type ? sanitize(opening_time.opening_type.name + ": " + opening_time.name) : nil
      end,
      :contacts => court.contacts.map do |contact|
        contact.contact_type ? sanitize(contact.contact_type.name + ": " + contact.telephone) : nil
      end,
      :emails => court.emails.map do |contact|
        contact.contact_type ? sanitize(contact.contact_type.name + ": " + contact.address) : nil
      end,
      :court_facilities => court.court_facilities.map do |facility|
        {
          :type => facility.facility ? sanitize(facility.facility.name) : nil,
          :text => sanitize(facility.description)
        }
      end,
      :court_types => court.court_types.map do |type|
        sanitize(type.name)
      end,
      :areas_of_law => court.areas_of_law.map do |area|
        sanitize(area.name)
      end
    }
    @ironmq = IronMQ::Client.new(:token => ENV["CF_IRONMQ_TOKEN"],
                                 :project_id => ENV["CF_IRONMQ_PROJECTID"])

    @queue = @ironmq.queue(ENV["CF_IRONMQ_QUEUENAME"])
    @queue.post(@court_to_be_serialised.to_json)
  end

  private
    def authorised?
      redirect_to admin_path unless current_user.admin?
    end

    def info_for_paper_trail
      ip = request.remote_ip
      {
        ip: ip
      }
    end

    def paper_trail_enabled_for_controller
      request.user_agent != 'Disable User-Agent'
    end

    def sanitize(text)
      ActionView::Base.full_sanitizer.sanitize(text).gsub(/\n|\r/, '')
    end
end
