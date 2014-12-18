require 'sinatra'
require 'sinatra/reloader'
require 'server'
require 'json'
require 'pp'
require 'open-uri'
require './config'

set :environment, :production

get '/show' do
  # 全ユーザ情報を取得
  res = open('https://' + $config['qiita_domain'] + '/api/v2/users?per_page=50', "Authorization" => $config['token'])
  code, message = res.status
  if code != '200'
    return nil
  end
  users = JSON.parse(res.read)
  @post_counts = Array.new
  users.each do |user|
    # ユーザに紐づく投稿を取得
    res = open('https://' + $config['qiita_domain'] + '/api/v2/users/' + user['id'] + '/items', "Authorization" => $config['token'])
    code, message = res.status
    if code != '200'
      return nil
    end
    posts = JSON.parse(res.read)
    post_count = {"id" => user['id'], "count" => posts.length}
    @post_counts.push(post_count)
  end
  @post_counts.sort_by!{|val| -val['count']}
 
  erb :index
end
