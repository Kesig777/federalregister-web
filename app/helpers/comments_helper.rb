module CommentsHelper
  def comment_input_field_options(field)
    options = {
      :label    => field.label,
      # :hint     => field.hint,
      :required => field.required?,
    }

    if field.publically_viewable?
      options[:wrapper_html] = {:class => "public"}
    end

    case field
    when RegulationsDotGov::CommentForm::Field::TextField
      # the regs.gov API returns a max-length of -1 to mean a textarea capped at 2000 characters
      if field.max_length > 0
        options.merge!(
          :as => :string,
          :size => field.max_length,
          :wrapper_html => {
            :'data-max-size' => field.max_length,
            :'data-size-warn-at' => 7
          }
        )
      else
        options.merge!(
          :as => :text,
          :wrapper_html => {
            :'data-max-size' => 2000,
            :'data-size-warn-at' => 1800
          }
        )
      end
    when RegulationsDotGov::CommentForm::Field::SelectField
      options.merge!(
        :as => :select,
        :collection => field.options,
        :member_value => :value,
        :member_label => :label
      )
    when RegulationsDotGov::CommentForm::Field::ComboField
      options.merge!(
        :as => :string,
        :wrapper_html => {
          :class => "combo",
          :'data-dependent-on' => field.dependent_on,
          :'data-dependencies' => field.dependencies.to_json
        }
      )
    end

    options
  end
end
