# SPDX-FileCopyrightText: 2020 ash_phoenix contributors <https://github.com/ash-project/ash_phoenix/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshPhoenix.Test.PricingEstimate do
  @moduledoc """
  Test resource for validating the prioritize_data_for option.

  Reproduces the issue where computed attributes that revert to their original
  values show stale param values instead of correct data values.
  """

  use Ash.Resource,
    domain: AshPhoenix.Test.Domain,
    data_layer: Ash.DataLayer.Ets

  ets do
    private? true
  end

  attributes do
    uuid_primary_key :id

    attribute :original_price, :integer, allow_nil?: false
    attribute :discount_price, :integer, allow_nil?: false
    attribute :final_price, :integer, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:original_price, :discount_price, :final_price]
    end

    update :update do
      primary? true
      accept [:original_price, :discount_price, :final_price]
      require_atomic? false

      # Recalculate final_price when discount_price or original_price changes
      change fn changeset, _context ->
        original = Ash.Changeset.get_attribute(changeset, :original_price)
        discount = Ash.Changeset.get_attribute(changeset, :discount_price)
        new_final = original - discount
        Ash.Changeset.change_attribute(changeset, :final_price, new_final)
      end
    end
  end
end
