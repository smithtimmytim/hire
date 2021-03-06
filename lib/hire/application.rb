require 'sinatra'
require 'chronic'

module Hire
  class Application < Sinatra::Base
    set :root, File.join(File.dirname(__FILE__), '../..')
    set :views, proc { File.join(root, 'views') }

    get '/' do
      @weeks = []
      start_date = Chronic.parse('Monday', context: :past)
      end_date = Chronic.parse('next Friday', now: start_date)
      today = Time.now

      10.times do |_i|
        start_string = start_date.strftime('%b %e').gsub(/\s+/, ' ')
        @weeks << {
          booked: (end_date < today || Hire.redis.get(start_string)),
          start_date: start_string,
          end_date: end_date.strftime('%b %e').gsub(/\s+/, ' ')
        }

        start_date = Chronic.parse('next Monday', now: end_date)
        end_date = Chronic.parse('next Friday', now: start_date)
      end

      haml :index, locals: { weeks: @weeks }
    end
  end
end
