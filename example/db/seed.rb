Buckets.connect.transaction do
  Buckets::User.create name: 'admin', is_admin: true
  %w{ bob chris dave }.each { |name| Buckets::User.create name: name }
  users = Buckets::User.all
  (1..7).each do |i|
    u = users.sample
    b = Buckets::Bucket.create user: u
    users.sample(2).each { |user| b.add_user user unless user == u }
    (1..5).each { |j| Buckets::Object.create bucket: b }
  end
end
