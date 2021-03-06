# frozen_string_literal: true

require_relative '../command'
require_relative '../api/tempo_api/requests/list_worklogs'

module TempestTime
  module Commands
    class List < TempestTime::Command
      def initialize(options)
        @user = find_user(options[:user])
        @dates = options[:date] ? [Date.parse(options[:date])] : nil
      end

      def execute!
        @dates ||= date_prompt(
          'Please select the dates you wish to view.',
          days_before: 13,
          days_after: 13
        ).sort
        @dates.each do |date|
          with_spinner(
            "Retrieving logs for #{pastel.yellow(@user.name)} "\
            "on #{pastel.yellow(formatted_date(date))}..."
          ) do |spin|
            @response = TempoAPI::Requests::ListWorklogs.new(
              date,
              end_date: nil,
              user: @user
            ).send_request
            spin.stop(pastel.green('Done!'))
            prompt.say(render_table)
            prompt.say(
              'Total Time Logged: '\
              "#{pastel.green("#{@response.total_hours_spent} hours")}"
            )
          end
        end
      end

      private

      def table_headings
        %w(Worklog Issue Time Description)
      end

      def render_table
        t = table.new(table_headings, @response.worklogs.map { |r| row(r) })
        t.render(
          :ascii,
          padding: [0, 1],
          column_widths: [7, 15, 15, 30],
          multiline: true
        )
      end

      def row(worklog)
        [
          worklog.id,
          worklog.issue,
          formatted_time(worklog.seconds),
          worklog.description,
        ]
      end
    end
  end
end
