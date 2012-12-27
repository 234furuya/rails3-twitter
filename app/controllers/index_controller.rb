# coding:utf-8

class IndexController < ApplicationController
  def index
    begin
      # sessionにログインデータがなかったとき戻る
      return unless session[:oauth]
      
      # sessionのデータをインスタンス変数@oauthに格納
      @oauth = session[:oauth]
      # アクセストークンをsessionのデータを渡して生成
      access_token = OAuth::AccessToken.new(
        self.class.consumer,
        session[:oauth][:token],
        session[:oauth][:secret]
      )
      # アクセストークンを用いてOAuthRubytterオブジェクトを生成
      rubytter = OAuthRubytter.new(access_token)
      # フォローしている人のツイートを取得
      @tweets = rubytter.friends_timeline
      # 自分への返信ツイートを取得
      @mentions = rubytter.replies
      # お気に入りツイートを取得
      @favorites = rubytter.favorites("")
      # 自分がしたリツイートを取得
      @retweets = rubytter.retweeted_by_me
    rescue Rubytter::APIError
      session.delete :oauth
    end
  end

  def tweet
    return unless session[:oauth]
    
    access_token = OAuth::AccessToken.new(
        self.class.consumer,
        session[:oauth][:token],
        session[:oauth][:secret]
      )
    rubytter = OAuthRubytter.new(access_token)
    
    # テキストエリア:tweetの内容をツイートする
    rubytter.update(params[:tweet])
    # indexにリダイレクト
    redirect_to :index
  end

  def oauth
    # コールバックURLを指定
    callback_url = "http://#{request.host_with_port}/callback"
    
    # リクエストトークンを発行し、request_tokenセッションに格納
    request_token = self.class.consumer.get_request_token(oauth_callback: callback_url)
    session[:request_token] = {
      token: request_token.token,
      secret: request_token.secret
    }
    
    # 認証URLへリダイレクト
    redirect_to request_token.authorize_url
  end

  def callback
    
    # 認証拒否された場合(:deniedが送られてきたとき)セッションをデリート
    if params[:denied]
      session.delete :oauth
    # 認証成功時
    else
      # セッションrequest_tokenの内容でリクエストトークンオブジェクトを生成
      request_token = OAuth::RequestToken.new(
        self.class.consumer,
        session[:request_token][:token],
        session[:request_token][:secret]
      )

    # リクエストトークンと認証で送られてきたoauth_tokenとoauth_varifierでアクセストークンを生成
      access_token = request_token.get_access_token(
        {},
        oauth_token: params[:oauth_token],
        oauth_verifier: params[:oauth_verifier]
      )
      
    # セッションにアクセストークンを格納
      session[:oauth] = {
        token: access_token.token,
        secret: access_token.secret
      }
    end
    
    # 不要になったリクエストトークンをデリート
    session.delete :request_token
    
    # indexへリダイレクト
    redirect_to :index
  end
  
  def favorite_action
    return unless session[:oauth]
    
    access_token = OAuth::AccessToken.new(
        self.class.consumer,
        session[:oauth][:token],
        session[:oauth][:secret]
      )
    rubytter = OAuthRubytter.new(access_token)
    # :idのツイートをお気に入りに入れる
    rubytter.favorite(params[:id])
    redirect_to :index
  end
  
  def retweet_action
    return unless session[:oauth]
    
    access_token = OAuth::AccessToken.new(
        self.class.consumer,
        session[:oauth][:token],
        session[:oauth][:secret]
      )
    rubytter = OAuthRubytter.new(access_token)
    
    # :idのツイートをリツイートする
    rubytter.retweet(params[:id],"")
    redirect_to :index
  end

  
  def logout
    session.delete :oauth
    redirect_to :index
  end
end
