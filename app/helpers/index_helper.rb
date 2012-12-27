# coding:utf-8

module IndexHelper
  # TwitterAPIで取得した日時を日本時間と日本語表記に直す
  def japan_date(tw_date)
    date = Time.parse(tw_date)
    # 曜日の名前を要素とした配列を生成
    week=["日","月","火","水","木","金","土"]
    # strftimeメソッドの曜日を数字化する表現を用いて、week配列から該当の曜日を取り出す
    weekday = week[date.strftime("%w").to_i]
    return date.strftime("%Y年%m月%d日(#{weekday})%H時%M分%S秒")
  end
end