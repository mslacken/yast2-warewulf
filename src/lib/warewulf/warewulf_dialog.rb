require "yast"
require "#{File.dirname(__FILE__)}/wwclient"

Yast.import "UI"
Yast.import "Label"

module WarewulfBase
  # Dialog to display journal entries with several filtering options
  class MockupDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      textdomain "warewulf"
      @nodelist = get_nodelist
    end
     
    # Displays the dialog
    def run
      return unless create_dialog

      begin
        return event_loop
      ensure
        close_dialog
      end
    end

  private

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # Header
          Heading(_("Warewulf Nodes")),


          # Filter checkboxes
          Frame(
            _("Filters"),
            additional_filters_widget
          ),
          VSpacing(0.3),

          # Refresh
          Right(PushButton(Id(:refresh), _("Refresh"))),
          VSpacing(0.3),

          # Log entries
          table,
          VSpacing(0.3),

          # Quit button
          PushButton(Id(:cancel), Yast::Label.QuitButton)
        )
      )
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    # Simple event loop 
    def event_loop
      loop do
        case Yast::UI.UserInput
        when :cancel
          # Break the loop
          break
        when :refresh
          get_nodelist
          puts "Refresh pressed"
        else
          log.warn "Unexpected input #{input}"
        end
      end
    end

    # Table widget to display log entries
    def table
      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(
          _("name"),
          _("profile"),
          _("container"),
        ),
        table_items
      )
    end
    def redraw_table    
      Yast::UI.ChangeWidget(Id(:entries_table), :Items, table_items)
    end



    # Widget containing a checkbox per filter
    def additional_filters_widget
      filters = [
        { name: :unit, label: _("For this systemd unit") },
      ]

      checkboxes = filters.map do |filter|
        name = filter[:name]
        Left(
          HBox(
            CheckBox(Id(name), filter[:label]),
            HSpacing(1),
            InputField(Id(:"#{name}_value"), "", "")
          )
        )
      end

      VBox(*checkboxes)
    end
    def table_items
      list = []
      nodes = @nodelist
      nodes.each{|node|
        list.push([node["id"]["value"],node["container"]["value"],node["profiles"].to_s])
      }
      list.map {|fields| Item(*fields) }
    end
    # read the node list
    def get_nodelist
      log.info "Calling get_node list"
      puts "in get_nodelist"
      @nodelist = Warewulf.node_list
    end
  end
end
