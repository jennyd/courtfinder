# TODO: this can be refactored into a nice DSL
class ApiDocsController < RestrictedController

  layout false
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html
      # format.json do
      #   render json: header_fields.merge({
      #     apis: [
      #       { path: "/api_docs/sync.{format}" },
      #       { path: "/api_docs/credentials.{format}" }
      #     ]
      #   })
      # end
    end
  end

  def get_token
    @token = current_channel.applications.first.access_tokens.new(
      resource_owner_id: current_user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
      use_refresh_token: true
    )
    @token.created_at = Time.now
    @token.save

    render json: {token: @token.token, refresh_token: @token.refresh_token}
  end

 # def list_channels
 #    {
 #      path: with_user_token('/channels.json'),
 #      description: 'List channels',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'List channels',
 #        notes: 'Returns list of available channels.',
 #        responseClass: 'json',
 #        nickname: 'channels',
 #        parameters: [],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def show_channel
 #    {
 #      path: with_user_token("/channels/{channel_id}.json"),
 #      description: 'Show channels',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show channel',
 #        notes: 'Returns data for given channel - includes data_collections, e.g. car_images, flag_images.',
 #        responseClass: 'json',
 #        nickname: 'channel',
 #        parameters: [
 #          name: 'channel_id',
 #          description: 'channel ID e.g. f1-2012',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: Channel.all.map(&:name).reverse
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ]
 #      ]
 #    }
 #  end

 #  def index_dashboard
 #    {
 #      path: with_user_token("/channels/{channel_id}/dashboard_events.json"),
 #      description: 'Show dashboard events',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show dashboard',
 #        notes: "Returns data for given channel's dashboard - includes live_session, next_session, past_events, live_events, future_events, season_pass",
 #        responseClass: 'json',
 #        nickname: 'dashboard',
 #        parameters: [
 #          name: 'channel_id',
 #          description: 'channel ID e.g. f1-2012',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: Channel.all.map(&:name).reverse
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ]
 #      ]
 #    }
 #  end

 #  def countdown_dashboard
 #    {
 #      path: with_user_token("/channels/{channel_id}/dashboard_countdown.json"),
 #      description: 'Show dashboard countdown',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show dashboard countdown',
 #        notes: "Returns countdown data for given channel's dashboard - includes live_session, next_session",
 #        responseClass: 'json',
 #        nickname: 'dashboard_countdown',
 #        parameters: [
 #          name: 'channel_id',
 #          description: 'channel ID e.g. f1-2012',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: Channel.all.map(&:name).reverse
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ]
 #      ]
 #    }
 #  end

 #  def list_events
 #    {
 #      path: with_user_token("/channels/{channel_id}/events.json"),
 #      description: 'List channel events',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'List channel events',
 #        notes: 'Returns list of events for given channel.',
 #        responseClass: 'json',
 #        nickname: 'channel_events',
 #        parameters: [
 #          name: 'channel_id',
 #          description: 'channel ID e.g. f1-2012',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: Channel.all.map(&:name).reverse
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def event_ids
 #    Channel.where(name: 'f1').first.all_events.map(&:code)
 #  end

 #  def show_event
 #    {
 #      path: with_user_token("/events/{event_id}.json"),
 #      description: 'Show event',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event',
 #        notes: 'Returns data on given event - including a list of sessions.',
 #        responseClass: 'json',
 #        nickname: 'event',
 #        parameters: [
 #          name: 'event_id',
 #          description: 'event ID e.g. f1-2012-19',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: event_ids
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def show_images
 #    {
 #      path: with_user_token("/events/{event_id}/images.json"),
 #      description: 'Show event images',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event images',
 #        notes: 'Returns images for given event - e.g. flag and car images',
 #        responseClass: 'json',
 #        nickname: 'event',
 #        parameters: [
 #          name: 'event_id',
 #          description: 'event ID e.g. f1-2012-19',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: event_ids
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def list_adverts
 #    {
 #      path: with_user_token("/events/{event_id}/adverts.json"),
 #      description: 'Show event adverts',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event adverts',
 #        notes: 'Returns adverts for given event',
 #        responseClass: 'json',
 #        nickname: 'event',
 #        parameters: [{
 #          name: 'event_id',
 #          description: 'event ID e.g. f1-2012-19',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: event_ids
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        }],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def show_adverts
 #    {
 #      path: with_user_token("/events/{event_id}/adverts/{advert_group_id}.json"),
 #      description: 'Show event adverts',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event adverts',
 #        notes: 'Returns adverts for given event',
 #        responseClass: 'json',
 #        nickname: 'event',
 #        parameters: [{
 #          name: 'event_id',
 #          description: 'event ID e.g. f1-2012-19',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: event_ids
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        },{
 #          name: 'advert_group_id',
 #          description: 'event ID e.g. 2',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: %w(0 1 2)
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        }],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def show_participants
 #    {
 #      path: with_user_token("/events/{event_id}/participants.json"),
 #      description: 'Show event participants',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event participants',
 #        notes: 'Returns participants for given event',
 #        responseClass: 'json',
 #        nickname: 'event',
 #        parameters: [
 #          name: 'event_id',
 #          description: 'event ID e.g. f1-2012-19',
 #          allowableValues: {
 #            valueType: 'LIST',
 #            values: event_ids
 #          },
 #          paramType: 'path',
 #          required: true,
 #          allowMultiple: false,
 #          dataType: 'string'
 #        ],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }

 #  end

 #  def show_session
 #    {
 #      path: with_user_token("/sessions/{session_code}.json"),
 #      description: 'Show event session',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event session',
 #        notes: 'Returns data on given event session - including a list of camera feeds.',
 #        responseClass: 'json',
 #        nickname: 'event_session',
 #        parameters: session_parameters,
 #        errorResponses: [ code: 401, reason: 'Authorization Required' ]
 #      ]
 #    }
 #  end

 #  def show_race_video_status
 #    {
 #      path: with_user_token("/sessions/{session_code}/race_video_status.json"),
 #      description: 'Show video status of a session',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show video status of a session',
 #        notes: 'Returns video status for flash and iOS.',
 #        responseClass: 'json',
 #        nickname: 'session_video_status',
 #        parameters: session_parameters,
 #        errorResponses: [ code: 401, reason: 'Authorization Required' ]
 #      ]
 #    }
 #  end

 #  def show_camera_feeds
 #    {
 #      path: with_user_token("/sessions/{session_code}/camera_feeds_list.json"),
 #      description: 'Show event session camer feed',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event session camera feed',
 #        notes: 'Returns list of camera feeds.',
 #        responseClass: 'json',
 #        nickname: 'event_session_camera_feeds',
 #        parameters: session_parameters,
 #        errorResponses: [ code: 401, reason: 'Authorization Required' ]
 #      ]
 #    }
 #  end

 #  def show_number_of_laps
 #    {
 #      path: with_user_token("/sessions/{session_code}/number_of_laps.json"),
 #      description: 'Show event session number of laps',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show event session number of laps',
 #        notes: 'Returns number of laps.',
 #        responseClass: 'json',
 #        nickname: 'event_session_number_of_laps',
 #        parameters: session_parameters,
 #        errorResponses: [ code: 401, reason: 'Authorization Required' ]
 #      ]
 #    }
 #  end

 #  def show_incidents
 #    {
 #      path: with_user_token("/sessions/{session_code}/incidents"),
 #      description: 'Show session incidents',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show session incidents',
 #        notes: 'Returns incidents for a given session',
 #        responseClass: 'json',
 #        nickname: 'session_incidents',
 #        parameters: session_parameters,
 #        errorResponses: [ code: 401, reason: 'Authorization Required' ]
 #      ]
 #    }
 #  end

 #  def session_parameters
 #    session_codes = if Season.where(name: 'f1-2012').first
 #      %w[19 6 18 15].collect {|round| Event.where(code: "f1-2012-#{round}").first.sessions.map(&:code).reverse }.flatten
 #    else
 #      codes = []
 #      Channel.where(name: 'f1').first.all_events.each {|e| codes << e.sessions.map(&:code) }
 #      codes.flatten
 #    end

 #    [
 #    {
 #      name: 'session_code',
 #      description: 'session code e.g. f1-2012-19-q1',
 #      allowableValues: {
 #        valueType: 'LIST',
 #        values: session_codes
 #      },
 #      paramType: 'path',
 #      required: true,
 #      allowMultiple: false,
 #      dataType: 'string'
 #    }
 #    ]
 #  end

 #  def show_authentication_uri
 #    {
 #      path: '/authentication_uri',
 #      description: 'Show DigiFortress authentication URI',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show authentication URI',
 #        notes: 'Returns URI to DigiFortress.',
 #        responseClass: 'json',
 #        nickname: 'auth_uri',
 #        parameters: [],
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def participant_parameters
 #    session_parameters + [
 #    {
 #      name: 'participant_tla',
 #      description: 'participant TLA e.g. VET',
 #      allowableValues: {
 #        valueType: 'LIST',
 #        values: Participant.only(:tla).map(&:tla).sort
 #      },
 #      paramType: 'path',
 #      required: true,
 #      allowMultiple: false,
 #      dataType: 'string'
 #    }
 #    ]
 #  end

 #  def show_votes
 #    {
 #      path: with_user_token("/sessions/{session_code}/participants/{participant_tla}/votes.json"),
 #      description: 'Show session votes for participant',
 #      operations: [
 #        httpMethod: 'GET',
 #        summary: 'Show likes / dislikes',
 #        notes: 'Returns session votes for given participant.',
 #        responseClass: 'json',
 #        nickname: 'session_votes',
 #        parameters: participant_parameters
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

 #  def like_vote
 #    register_vote 'like'
 #  end

 #  def dislike_vote
 #    register_vote 'dislike'
 #  end

 #  def register_vote vote_type
 #    {
 #      path: with_user_token("/sessions/{session_code}/participants/{participant_tla}/#{vote_type}.json"),
 #      description: "Register #{vote_type} vote for participant in session",
 #      operations: [
 #        httpMethod: 'POST',
 #        summary: "#{vote_type.humanize} vote",
 #        notes: "Register #{vote_type} vote for participant in session. Returns session votes for given participant.",
 #        responseClass: 'json',
 #        nickname: "#{vote_type}_votes",
 #        parameters: participant_parameters
 #        # errorResponses: [ code: 400, reason: 'Invalid username and password combination' ]
 #      ]
 #    }
 #  end

  # def authentication_uri
  #   render json: header_fields.merge( apis: [show_authentication_uri] )
  # end

  # def sync
  #   render json: header_fields.merge( apis: [sync_json] )
  # end

  # def credentials
  #   render json: header_fields.merge( apis: [credentials_json] )
  # end

  # def channels
  #   render json: header_fields.merge( apis: [list_channels, show_channel, index_dashboard, countdown_dashboard] )
  # end

  # def events
  #   render json: header_fields.merge( apis: [show_event, show_images, show_participants, show_adverts, list_adverts] )
  # end

  # def sessions
  #   render json: header_fields.merge(
  #     apis: [show_session, show_incidents, show_votes, like_vote, dislike_vote, show_race_video_status, show_camera_feeds, show_number_of_laps] )
  # end

  # protected

  # def sync_json
  #   {
  #     path: '/sync',
  #     description: 'Sync',
  #     operations: [
  #       httpMethod: 'POST',
  #       summary: 'Sync poll endpoint',
  #       notes: 'Path to wiki',
  #       responseClass: 'json',
  #       nickname: 'sync_post',
  #       produces: [
  #         "application/json",
  #         "application/xml"
  #       ],
  #       parameters: [
  #         parameter(
  #           name: 'device[device_license]',
  #           description: 'Device license, if not provided a new license will be generated',
  #         ),parameter(
  #           name: 'device[app_version]',
  #           description: 'Current application version',
  #           required: true,
  #         ),parameter(
  #           name: 'device[device_status]',
  #           description: 'The status of the app',
  #           required: true,
  #           allowableValues: {
  #             valueType: 'LIST',
  #             values: ['N','L','S','A']
  #           }
  #         ),parameter(
  #           name: 'device[app_id]',
  #           description: 'Application uuid for an oauth application (has to be valid)',
  #           required: true,
  #           allowableValues: {
  #             valueType: 'LIST',
  #             values: Doorkeeper::Application.all.map{|a| [a.uuid]}
  #           }
  #         ),parameter(
  #           name: 'device[manufacturer]',
  #           description: 'Device manufacturer',
  #         ),parameter(
  #           name: 'device[model]',
  #           description: 'Device model'
  #         ),parameter(
  #           name: 'device[location]',
  #           description: 'The latitude and logitude in the format <lat>,<lng>'
  #         ),parameter(
  #           name: 'device[net_type]',
  #           description: 'Type of network connection being used'
  #         ),parameter(
  #           name: 'device[device_time]',
  #           description: 'Local time on device',
  #           required: true,
  #           dataType: 'dateTime',
  #           defaultValue: Time.now.utc
  #         ),parameter(
  #           name: 'device[device_timezone]',
  #           description: 'Timezone on the device'
  #         ),parameter(
  #           name: 'device[last_sync]',
  #           description: 'The last time the app completed a successful sync (should be based on server UTC) no required but if not supplied a full sync will proceed'
  #         )
  #       ]
  #     ]
  #   }
  # end

  # def credentials_json
  #   {
  #     path: '/me',
  #     description: 'Credentials',
  #     operations: [
  #       httpMethod: 'GET',
  #       summary: 'Credentials endpoint',
  #       notes: 'Path to credentials',
  #       responseClass: 'json',
  #       nickname: 'credentials_me',
  #       produces: [
  #         "application/json",
  #         "application/xml"
  #       ],
  #       parameters: []
  #     ]
  #   }
  # end

  # def parameter(data)
  #   {
  #     paramType: 'form',
  #     required: false,
  #     allowMultiple: false,
  #     dataType: 'string'
  #   }.merge(data)
  # end

  # def with_user_token path
  #   if session[:user_token].present?
  #     "#{path}?user_token=#{session[:user_token]}"
  #   else
  #     path
  #   end
  # end

  # def header_fields
  #   api_url = APP_CONFIG[:api_url].gsub('{channel}.', ApplicationController.current_channel ? "#{ApplicationController.current_channel.channel_key}." : '')

  #   {
  #     apiVersion: "1",
  #     swaggerVersion: "1.1",
  #     basePath: api_url,
  #   }
  # end

end