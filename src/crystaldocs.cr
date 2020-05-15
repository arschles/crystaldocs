require "kemal"
require "nuummite"
require "process"
require "dir"


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
        shard_vcs_url = "https://github.com/#{shard_org}/#{shard_name}.git"

        clone_dir = "#{shard_org}/#{shard_name}"
        Dir.mkdir_p(clone_dir)

        clone_args = [
          "clone",
          shard_vcs_url,
          clone_dir,
        ]
        exec_env = {
          "PATH" => "/home/linuxbrew/.linuxbrew/bin/:/usr/bin/:/usr/local/bin/",
        }
        clone_process = Process.new(
          "git",
          args: clone_args,
          env: exec_env,
          shell: true
          # TODO: figure out how to specify an output IO
          # so that we can get the output later, if
          # the command fails
          # TODO: chdir
        )
        output = clone_process.output?
        if !clone_process.wait.success?
          if !output.nil?
            print "output = #{output.gets_to_end}"
          else
            print "no output available"
          end
          halt env, status_code: 500, response: "Couldn't clone"
        end

        docs_process = Process.new(
          "crystal",
          args: ["docs"],
          chdir: clone_dir,
          shell: true
        )                
        if !docs_process.wait.success?
          halt env, status_code: 500, response: "Couldn't generate docs"
        end

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
        docs_dir = "#{clone_dir}/docs"

        # TODO: read all the other asset files into the DB
        # in addition to index.html
        file = File.new("#{docs_dir}/index.html")
        index_html_content = file.gets_to_end
        file.close
        db[db_key] = index_html_content

        # then, copy the "index.html" out and put it into the DB
        # under the "#{shard_org}/#{shard_name}/index.html" key

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
