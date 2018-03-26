namespace :canaid do
  MD_FILE_PATH = 'permissions.md'
  GENERIC_CLASS_NAME = 'Canaid::PermissionsHolder::Generic'

  def print(markdown = false)
    # Fetch variables off the permissions holder instance
    ph = Canaid::PermissionsHolder.instance
    can_obj_classes = ph.instance_variable_get(:@can_obj_classes)
    cans = ph.instance_variable_get(:@cans)

    output = []

    obj_classes = can_obj_classes
                  .values
                  .select { |oc| oc != GENERIC_CLASS_NAME }
    # Start with generic
    obj_classes.unshift(GENERIC_CLASS_NAME)

    obj_classes.uniq.each do |obj_class|
      if obj_class == GENERIC_CLASS_NAME
        output << '## Generic permissions'
      else
        output << "## #{obj_class} permissions"
      end
      output << ''

      permission_names =
        can_obj_classes.map { |k, v| v == obj_class ? k : nil }.compact
      permission_names.sort!
      permission_names.each do |pn|
        next if cans[pn].empty?


        output << "*#{pn}*" if markdown
        perms = cans[pn].sort { |e1, e2| e1[:priority] <=> e2[:priority] }
        perms.each_with_index do |perm, idx|
          output << '```' if markdown
          output << perm[:block].source
          output << '```' if markdown
        end

#        # Extract parameters from first block
#        md = /.*\|(.*)\|.*/.match(cans[pn][0][:block].source.split("\n")[0])
#        params = md && md.length > 1 ? md[1] : ''
#        if markdown
#          output << ["**can_#{pn}?(#{params})**", '', '```' ]
#        else
#          output << "can_#{pn}?(#{params})"
#        end
#
#        # Print individual permissions
#        perms = cans[pn].sort { |e1, e2| e1[:priority] <=> e2[:priority] }
#        perms.each_with_index do |perm, idx|
#          src = perm[:block].source
#          md = /\A\s*can.*(do|\{)\s*(\|.*\|)?(.*)(end|\})\s*\z/m.match(src)
#          next unless md.length == 5
#          res = md[3]
#                .strip
#                .split("\n")
#                .map(&:strip)
#                .map { |v| "  #{v}" }
#                .join("\n")
#          res = "#{res} &&" if perms.length > 1 && idx < perms.length - 1
#          output << res
#        end
#        output << '```' if markdown

        output << ''
      end
    end

    return output.join("\n")
  end

  desc 'Print all permissions definitions'
  task print: :environment do
    puts print(false)
  end

  desc 'Save all permissions definitions to permissions.md'
  task print_md: :environment do
    File.delete(MD_FILE_PATH) if File.exist?(MD_FILE_PATH)
    File.open(MD_FILE_PATH, 'w') do |file|
      file.write(print(true))
    end
  end
end
