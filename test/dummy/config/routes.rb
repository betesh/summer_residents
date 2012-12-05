Rails.application.routes.draw do

  root :to => 'summer_residents/families#index'
  mount SummerResidents::Engine => "/fams"
end
