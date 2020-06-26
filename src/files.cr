module Files
    extend self

    def write_to_dir(
        fully_qualified_filename : String,
        contents : String
    )
        # file = File.open(
        #     filename = fully_qualified_filename,
        #     mode = "w"
        # )

        # TODO: create the file first!
        File.write(fully_qualified_filename, contents)
    end
end

        