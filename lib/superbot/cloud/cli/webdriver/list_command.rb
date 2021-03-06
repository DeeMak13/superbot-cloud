# frozen_string_literal: true

module Superbot
  module Cloud
    module CLI
      module Webdriver
        class ListCommand < BaseCommand
          OUTPUT_HEADERS = {
            session_id: "Session ID",
            created_at: "Created at",
            updated_at: "Last activity"
          }.freeze

          option %w[-q --quiet], :flag, "Only show webdriver session IDs"
          option %w[-a --all], :flag, "Show all the sessions (including finished)"

          def execute
            list_sessions
          end

          def list_sessions
            states = all? ? nil : %w[idle proxying]
            api_response = Superbot::Cloud::Api.request(:webdriver_session_list, params: { organization_name: organization, 'aasm_state[]': states })
            abort "No active sessions found for #{api_response[:organization]} organization" if api_response[:webdriver_sessions].empty?

            if quiet?
              puts(api_response[:webdriver_sessions].map { |session| session[:session_id] })
            else
              puts "Organization: #{api_response[:organization]}"
              puts OUTPUT_HEADERS.values.map { |header| header.ljust(35) }.join
              puts ''.ljust(35 * OUTPUT_HEADERS.length, '-')
              api_response[:webdriver_sessions].each do |webdriver_session|
                puts webdriver_session.slice(*OUTPUT_HEADERS.keys).values.map { |v| v.to_s.ljust(35) }.join
              end
            end
          end
        end
      end
    end
  end
end
