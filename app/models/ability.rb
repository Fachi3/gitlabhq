class Ability
  def self.allowed(object, subject)
    case subject.class.name
    when "Project" then project_abilities(object, subject)
    when "Issue" then issue_abilities(object, subject)
    when "Note" then note_abilities(object, subject)
    when "Snippet" then snippet_abilities(object, subject)
    when "Wiki" then wiki_abilities(object, subject)
    else []
    end
  end

  def self.project_abilities(user, project)
    rules = []

    rules << [
      :read_project,
      :read_wiki,
      :read_issue,
      :read_snippet,
      :read_team_member,
      :read_merge_request,
      :read_note,
      :write_project,
      :write_issue,
      :write_snippet,
      :write_merge_request,
      :write_note
    ] if project.guest_access_for?(user)

    rules << [
      :download_code,
    ] if project.report_access_for?(user)

    rules << [
      :write_wiki
    ] if project.dev_access_for?(user)

    rules << [
      :modify_issue,
      :modify_snippet,
      :modify_wiki,
      :admin_project,
      :admin_issue,
      :admin_snippet,
      :admin_team_member,
      :admin_merge_request,
      :admin_note,
      :admin_wiki
    ] if project.master_access_for?(user)


    rules.flatten
  end

  class << self
    [:issue, :note, :snippet, :merge_request].each do |name|
      define_method "#{name}_abilities" do |user, subject|
        if subject.author == user
          [
            :"read_#{name}",
            :"write_#{name}",
            :"modify_#{name}",
            :"admin_#{name}"
          ]
        else
          subject.respond_to?(:project) ?
            project_abilities(user, subject.project) : []
        end
      end
    end
  end
end
