Sequel.migration do
  change do
    create_table(:buckets) do
      primary_key :id
      foreign_key :user_id, :users, null: false
    end

    create_table(:objects) do
      primary_key :id
      foreign_key :bucket_id, :buckets, null: false
    end

    create_table(:users) do
      primary_key :id
      String :name, unique: true, null: false
    end

    create_join_table(
      { :user_id => :users, :bucket_id => :buckets },
      { :name => :shares }
    )
  end
end
