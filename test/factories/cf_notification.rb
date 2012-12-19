# -*- coding: utf-8 -*-

FactoryGirl.define do
  factory :cf_notification do
    subject "Use the force!"
    body { generate(:random_string) }
    is_read false

    association :recipient, :factory => :cf_user
  end
end


# eof
