class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def import_projects
    WixService.new.get_products

    redirect_to projects_path
  end
end
