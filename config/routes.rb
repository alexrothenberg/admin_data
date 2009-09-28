
ActionController::Routing::Routes.draw do |map|
  map.namespace :admin_data do |admin_data|

    admin_data.with_options :controller => 'main' do |m|
      m.index                             '/' ,                       :action => 'all_models'
    end

    admin_data.with_options :controller => 'diagnostic' do |m|
      m.diagnostic                        '/diagnostic',              :action => 'index'
      m.diagnostic_missing_index          '/missing_index',           :action => 'missing_index'
    end

    admin_data.with_options :controller => 'migration' do |m|
      m.migration_information             '/migration',               :action => 'index'
    end


    admin_data.with_options :controller => 'search' do |m|
      m.search_on_model                   '/:klass/quick_search',     :action => 'quick_search'
      m.advance_search_on_model           '/:klass/advance_search',   :action => 'advance_search'
    end

    admin_data.resources :on_model, 
                         :as          => ':klass', 
                         :path_prefix => 'admin_data',
                         :controller  => 'main', 
                         :member      => {:delete          => :delete},
                         :collection  => {:table_structure => :any   }
  end

end
