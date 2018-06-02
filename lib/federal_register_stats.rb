class FederalRegisterStats
  attr_reader :beginning_of_month,
    :beginning_of_year,
    :date,
    :end_of_month,
    :launch_date

  def initialize(date, env='production')
    #site launched on this day - no stats make sense before this
    @launch_date = Date.parse('2010-07-26')

    @date = Date.parse(date)
    @beginning_of_year = @date.beginning_of_year
    @beginning_of_month = @date.beginning_of_month
    @end_of_month = @date.end_of_month
  end

  def generate
    puts "Total # of Subscriptions:  #{subscriptions(launch_date, end_of_month)}"
    puts "YTD # of Subscriptions:  #{subscriptions(beginning_of_year, end_of_month)}"
    puts "New Subscriptions in #{beginning_of_month.strftime('%B')}: #{subscriptions(beginning_of_month, end_of_month)}"

    puts "Total # of Comments in #{beginning_of_month.strftime('%B')} via Regulations.gov API integration:  #{comments_submitted}"
    puts "Total # of Comment Forms opened in #{beginning_of_month.strftime('%B')} on FederalRegister.gov:  #{comment_forms_opened}"
  end

  private

  def subscriptions(start_date = nil, end_date = nil)
    query = Subscription.where("confirmed_at IS NOT NULL AND unsubscribed_at IS NULL")

    if start_date
      query.where("created_at >= ? && created_at <= ?",start_date.to_s(:db), end_date.to_s(:db)).count
    else
      query.count
    end
  end

  def comments_submitted
    $redis.keys("comment_post_success:#{redisize_date(beginning_of_month)}").map{|k| Hash[$redis.zrangebyscore(k, 0, 1000, with_scores: true)].values}.flatten.sum.to_i
  end

  def comment_forms_opened
    $redis.keys("comment_opened:#{redisize_date(beginning_of_month)}").map{|k| Hash[$redis.zrangebyscore(k, 0, 1000, with_scores: true)].values}.flatten.sum.to_i
  end

  def redisize_date(date)
    date.strftime('%Y-%m*')
  end
end
