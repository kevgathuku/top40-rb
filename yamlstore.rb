require 'yaml/store'

store = YAML::Store.new "top40singles.yaml"
Single = Struct.new :title, :artist, :id

store.transaction do
  store['top40'] ||= []
  store['top40'].push Single.new 'Uptown Funk (feat. Bruno Mars)',
    'Mark Ronson', 'OPf0YbXqDm0'
  store['top40'].push Single.new 'Take Me To Church', 'Hozier',
    'MYSVMgRr6pw'
end
