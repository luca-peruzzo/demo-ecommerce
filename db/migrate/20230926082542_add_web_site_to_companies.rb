class AddWebSiteToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :web_site, :string
  end
end
