namespace :update do
  desc 'Updating corrupt blobs filename'
  task wrong_blob_filename: :environment do
    blobs = ActiveStorage::Blob.where('filename LIKE ?', '%?%')

    puts "Number of Blobs:  #{blobs.count}"

    blobs.each do |blob|
      puts "corrupted blob filename:  #{blob.filename}"
      blob.update_column(:filename, blob.filename.to_s.split('?')[0])
      puts "updated blob filename:  #{blob.filename}"
    end
    puts 'Updated!'
  end
end
