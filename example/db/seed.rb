require './buckets'

db = Buckets.connect
db.transaction do
  Buckets::User.create name: 'admin', is_admin: true
  %w{ bob chris dave }.each do |name|
    Buckets::User.create name: name
  end
  users = Buckets::User.all
  (1..7).each do |i|
    u = users.sample
    b = Buckets::Bucket.create user: u
    users.sample(2).each do |user|
      b.add_user user unless user == u
    end
    (1..5).each do |j|
      Buckets::Object.create bucket: b
    end
  end
end
