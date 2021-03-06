module Admin
  class OrganizationPagesController < BaseController
    inherit_resources
    singleton_belongs_to :language
    actions :all, except: [:show, :index]

    def create
      create! { admin_organization_pages_path }
    end

    def update
      update! { admin_organization_pages_path }
    end

    def destroy
      destroy! { admin_organization_pages_path }
    end

    protected
    def permitted_params
      params.permit(organization_page: [:main_text, :image, :title1, :text1, :title2, :text2, :title3, :text3, :title4, :text4])
    end

    def resource
      @organization_page ||= OrganizationPage.find(params[:id])
    end

    def build_resource
      @organization_page = Language.find(params[:language_id]).build_organization_page(permitted_params[:organization_page])
    end
  end
end
