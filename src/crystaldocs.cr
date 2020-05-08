require "kemal"
require "nuummite"
require "process"


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

        clone_process = Process.new(
          "git clone",
          shard_vcs_url,
          "#{shard_org}/#{shard_name}",
          # TODO: chdir
        )
        if !clone_process.wait.success?
          halt env, status_code: 500, response: "Couldn't clone"
        end

        docs_process = Process.new(
          "crystal docs",
          chdir="#{shard_org}/#{shard_name}"
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
