require 'json'

def remember_last_result
  warn 'Remembering last result'
  `mv #{current_result_path} #{previous_result_path}` if File.exist?(current_result_path)
end

def board_id = ENV.fetch('AOC_BOARD_ID')
def session = ENV.fetch('AOC_SESSION')
def slack_hook = ENV.fetch('AOC_SLACK_HOOK')
def previous_result_path = 'data/previous.json'
def current_result_path = 'data/current.json'

def needs_init? = !File.exist?(previous_result_path)

def fetch_new
  warn 'Fetching new result'
  json = `curl 'https://adventofcode.com/2024/leaderboard/private/view/#{board_id}.json' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
    -H 'cookie: session=#{session}' \
    -H 'priority: u=0, i' \
    -H 'upgrade-insecure-requests: 1'`
  File.write(current_result_path, json)
end

def current_result_age_seconds
  Time.now.to_i -
  (File.stat(current_result_path).mtime).to_i
end

def parse_result(file_path)
  JSON.parse(File.read(file_path))
    .fetch('members')
    .map do |_id, member|
      [member['name'], member['stars']]
    end
    .to_h
end

def current_result = parse_result(current_result_path)
def previous_result = parse_result(previous_result_path)

def results_differ? = current_result != previous_result

def result_differences
  current = current_result
  previous = previous_result

  current.filter do |name, stars|
    (previous[name] || 0) != stars
  end
end

def stars_per_member(result)
  members = result['members']
  members.map do |_id, member|
    [member['name'], member['stars']]
  end.to_set
end

def diff_results(previous, current)
  current.filter do |name, stars|
    (previous[name] || 0) != stars
  end
end

def run_init
  warn 'No previous result found. Running initial fetch.'
  fetch_new
  remember_last_result
  fetch_new
end

def message(text)
  puts(text)
end

def message_slack(text)
  data = { text: text }
  `curl -X POST -H 'Content-type: application/json' --data '#{JSON.generate(data)}' #{slack_hook}`
end

def run_diff
  if current_result_age_seconds < 900
    warn "Current result (age: #{current_result_age_seconds}s) is within the rate limit of 15 min. (900s)."
    return
  end

  remember_last_result
  fetch_new

  if results_differ?
    result_differences.each do |name, stars|
      start_diff = stars - (previous_result[name] || 0)
      message_slack("#{name} earned #{"⭐" * start_diff} for a total of ⭐#{stars}")
    end
  else
    warn 'Results are the same.'
    return
  end
end

def main
  if needs_init?
    run_init
  else
    run_diff
  end
end


if ARGV.include?('--deamon')
  warn 'Running in deamon mode'
  loop do
    main
    warn 'Sleeping. Will try again in a minute.'
    sleep(60)
  end
else
  main
end
