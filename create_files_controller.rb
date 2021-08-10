class CreateFilesController < ApplicationController
    require "csv"
    require 'rails/all'
    require "zlib"
    require 'fileutils'

    def query_date
        if params[:dateFrom].present? && params[:dateTo].present?
            @coordinates = params[:coordinates_to_check].split(",")
            if params[:aitia_select] == "Θερμοκρασία"
                database_name = Temprature
            elsif params[:aitia_select] == "Υγρασία"
                database_name = Humidity
            elsif params[:aitia_select] == "Πίεση στο επίπεδο της θάλασσας"
                database_name = SeaLevelPressure
            elsif params[:aitia_select] == "Άνεμος"
                database_name = Wind10M
            elsif params[:aitia_select] == "Βροχόπτωση"
                database_name = Precipitation
            elsif params[:aitia_select] == "Χαμηλή νέφωση"
                database_name = Cloudiness
            end
            @data = Temprature.where("loc.0" => {'$gte':@coordinates[1].to_f,'$lte':@coordinates[3].to_f},"loc.1" => {'$gte':@coordinates[0].to_f,'$lte':@coordinates[2].to_f}, 'year' => {'$gte':params[:dateFrom],'$lte':params[:dateTo]}, 'month' => {'$gte':params[:monthFrom],'$lte':params[:monthTo]}).pluck(:daily_values).to_a 
            @write_csv = @data.transpose
            @file_on = "#{params[:dateFrom]}-#{params[:dateTo]}"
            CSV.open(@file_on, "wb") do |csv|
               csv << @data
            end
        else
            @data = Temprature.all
        end
        compress_file(@file_on)
        #print(@data)
        redirect_to "/download_file.gz"
    end

    def compress_file(file_name)
        zipped = "download_file.gz"

        Zlib::GzipWriter.open(zipped) do |gz|
            gz.mtime = File.mtime(file_name)
            gz.orig_name = file_name
            gz.write IO.binread(file_name)
        end
        FileUtils.mv(zipped, 'public/'+ zipped)
        
    end

end
