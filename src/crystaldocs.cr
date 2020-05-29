require "kemal"
require "nuummite"
require "process"
require "dir"
require "io"
require "http/client"
require "zip"
require "./http.cr"


# TODO: Write documentation for `Crystaldocs`
module Crystaldocs

  db = Nuummite.new(".", "cprox.db")

  VERSION = "0.1.0"

  # crystaldocs.dev/arschles/myshard/
  #   db["arschles/myshard/index.html"]
  
  get "/:shard_org/:shard_name" do |env|
    shard_org : String | Nil = env.params.url["shard_org"]?
    shard_name: String | Nil = env.params.url["shard_name"]?

    if shard_org.nil?
      "Shard organization is required"
    elsif shard_name.nil?
      "Shard name is required"
    else
      db_key = "#{shard_org}/#{shard_name}/index.html"
      shard_docs = db[db_key]?
      if shard_docs.nil?
        shard_vcs_url = "https://github.com/CodeSteak/Nuummite/archive/master.zip"
        # shard_vcs_url = "https://github.com/#{shard_org}/#{shard_name}.git"

        mb_response = HTTPUtils.get(shard_vcs_url)
        if mb_response.nil?
          halt env, status_code: 500, response: "Couldn't download code zip file, no response"
        else
          puts mb_response.body.lines.first
          mb_io : IO | Nil = mb_response.body_io?
          if mb_io.nil?
            halt env, status_code: 500, response: "Couldn't download code zip file, no IO"
          else
            Zip::Reader.open(mb_io) do |zip|
              zip.each_entry do |entry|
                puts entry.filename
              end
            end
          end
        end
        # clone_dir = "customdocs/#{shard_org}/#{shard_name}"
        # puts "Trying to create directory #{clone_dir}\n"
        # Dir.mkdir_p(clone_dir)

        # clone_args = [
        #   "git",
        #   "clone",
        #   shard_vcs_url,
        #   clone_dir,
        # ]
        # exec_env = {
        #   "PATH" => "/home/linuxbrew/.linuxbrew/bin/:/usr/bin/:/usr/local/bin/",
        # }
        # output_io = IO::Memory.new
        # err_io = IO::Memory.new
        # clone_process = Process.new(
        #   "bash",
        #   args: clone_args,
        #   env: exec_env,
        #   shell: true,
        #   output: output_io,
        #   error: err_io,
        #   # TODO: figure out how to specify an output IO
        #   # so that we can get the output later, if
        #   # the command fails
        #   # TODO: chdir
        # )
        # puts output_io.to_s
        # puts "\n"
        # puts err_io.to_s
        # puts "\n"
        # output = clone_process.output?
        # if !clone_process.wait.success?
        #   if !output.nil?
        #     puts "output = #{output.gets_to_end}"
        #   else
        #     puts "no output available\n"
        #   end
        #   puts "we couldn't clone but don't know why!!!\n"
        #   halt env, status_code: 500, response: "Couldn't clone"
        # end

        # docs_process = Process.new(
        #   "crystal",
        #   args: ["docs"],
        #   chdir: clone_dir,
        #   shell: true
        # )                
        # if !docs_process.wait.success?
        #   halt env, status_code: 500, response: "Couldn't generate docs"
        # end

        # TODO: figure out how to get the _rest_ of the crystal
        #       docs files into the DB
        
        # TODO: fetch and render the docs.
        #
        # 1. ✔fetch the source code (using git clone?)
        # 2. ✔cd into the new source code directory
        # 3. ✔run crystal docs
        #     see https://forum.crystal-lang.org/t/hosted-documentation-site/1896/32 for more detail
        # 4. ?
        # 5. PROFIT! somehow (!) copy the docs into the database
        
        # go into this directory
        # docs_dir = "#{clone_dir}/docs"

        # # TODO: read all the other asset files into the DB
        # # in addition to index.html
        # file = File.new("#{docs_dir}/index.html")
        # index_html_content = file.gets_to_end
        # file.close
        # db[db_key] = index_html_content

        # # then, copy the "index.html" out and put it into the DB
        # # under the "#{shard_org}/#{shard_name}/index.html" key

        "No documentation available for shard #{shard_org}/#{shard_name}"
      else
        shard_docs
      end
    end
    # key_value_pairs = get_kvps(db)
    # render "src/views/index.ecr"
  end

  Kemal.run
end
