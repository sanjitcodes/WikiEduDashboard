require 'rails_helper'
require "#{Rails.root}/lib/importers/upload_importer"

describe UploadImporter do
  describe '.import_all_uploads' do
    it 'should find and record files uploaded to Commons' do
      create(:user,
             wiki_id: 'Guettarda')
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
        expect(CommonsUpload.all.count).to be > 50
      end
    end
  end

  describe '.update_usage_count' do
    it 'should count and record how many times files are used' do
      create(:user,
             wiki_id: 'Guettarda')
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
      end
      VCR.use_cassette 'commons/update_usage_count' do
        UploadImporter.update_usage_count(CommonsUpload.all)
        peas_photo = CommonsUpload.find(543972)
        expect(peas_photo.usage_count).to be > 1
      end
    end
  end

  describe '.import_urls_in_batches' do
    it 'should find and record Commons thumbnail urls' do
      create(:user,
             wiki_id: 'Guettarda')
      VCR.use_cassette 'commons/import_all_uploads' do
        UploadImporter.import_all_uploads(User.all)
      end
      VCR.use_cassette 'commons/import_urls_in_batches' do
        UploadImporter.import_urls_in_batches([CommonsUpload.find(543972)])
        peas_photo = CommonsUpload.find(543972)
        expect(peas_photo.thumburl[0...24]).to eq('https://upload.wikimedia')
      end
    end
  end
end
