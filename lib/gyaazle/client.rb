module Gyaazle
  class Client
    attr_reader :agent, :config

    def initialize(config)
      @config = config
      @agent = HTTPClient.new
    end

    def authorize_url
      url = "https://accounts.google.com/o/oauth2/auth?client_id=#{config.id}&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=https://www.googleapis.com/auth/drive"
      Nokogiri::HTML.parse(agent.get(url).body).at('a').attributes["href"].to_s
    end

    def get_tokens(verifier)
      agent.post_content("https://accounts.google.com/o/oauth2/token",{
        :code => verifier,
        :client_id => config.id,
        :client_secret => config.secret,
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
        :grant_type => "authorization_code",
      })
    end

    def refresh_token!
      json = agent.post("https://accounts.google.com/o/oauth2/token", {
        :refresh_token => credentials[:refresh_token],
        :client_id => config.id,
        :client_secret => config.secret,
        :grant_type => "refresh_token",
      }).body
      config.update(:access_token => MultiJson.load(json)["access_token"])
      config.load
    end

    def upload(file, metadata = nil)
      body = [
        {
          'Content-Type' => 'application/json;charset=utf-8',
          :content => MultiJson.dump(metadata || {
            :title => File.basename(file),
            :shared => "true",
            :parents => [:id => folder_id]
          })
        },
        {
          :content => File.read(file),
        },
      ]

      response = agent.post(
        'https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart',
        body,
        {
          "Authorization" => authorization_header_value,
          "Content-Type" =>  "multipart/related; boundary=___#{Time.now.to_f}___",
        }
      )
      # Note: deeplink is https://drive.google.com/uc?export=view&id={fileId}
      MultiJson.load(response.body, :symbolize_keys => true)
    end

    def set_permissions(file_id, permissions = nil)
      json = MultiJson.dump(
        permissions || credentials[:permissions] || {
          :role => "reader",
          :type => "#{"anyone"}",
          :value => "#{"me"}",
          :withLink => "true",
          :additionalRoles => ["commenter"],
        }
      )
      agent.post_content(
        "https://www.googleapis.com/drive/v2/files/#{file_id}/permissions",
        json,
        {
          "Authorization" => authorization_header_value,
          'Content-Type' => 'application/json;charset=utf-8',
        }
      )
    end

    def get_file_info(file_id)
      json = agent.get(
        "https://www.googleapis.com/drive/v2/files/#{file_id}",
        nil,
        {
          "Authorization" => authorization_header_value,
        }
      ).body

      MultiJson.load(json, :symbolize_keys => true)
    end

    def authorization_header_value
      "#{credentials[:token_type]} #{credentials[:access_token]}"
    end

    def folder_id
      id = credentials[:folder_id]
      return create_folder("Gyaazle") unless id

      folder = get_file_info(id)
      if !folder[:id] || folder[:labels][:trashed]
        create_folder("Gyaazle") 
      else
        id
      end
    end

    def create_folder(name)
      json = agent.post_content(
        "https://www.googleapis.com/drive/v2/files",
        MultiJson.dump({
          :title => name,
          :mimeType => "application/vnd.google-apps.folder",
          :parents => [{:id => "root"}],
        }),
        {
          "Authorization" => authorization_header_value,
          'Content-Type' => 'application/json;charset=utf-8',
        }
      )
      folder = MultiJson.load(json, :symbolize_keys => true)
      config.update(:folder_id => folder[:id])
      folder[:id]
    end

    def credentials
      config.load
    end
  end
end
