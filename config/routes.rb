SummerResidents::Engine.routes.draw do
  root to: 'families#index'
  js_constraint = { constraints: { format: /js/ } }

  controller :families do
    get 'add_my_family' => :add_user_info
  end
  resources :families, except: [:edit, :update, :destroy]
  resources :families, js_constraint.merge({ only: [:destroy]})
  resources :bungalows, js_constraint.merge({ except: [:index, :show]})
  resources :homes, js_constraint.merge({ except: [:index, :show]})
  resources :residents, js_constraint.merge({ except: [:index, :show]})
end
