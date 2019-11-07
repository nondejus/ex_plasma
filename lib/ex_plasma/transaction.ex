defmodule ExPlasma.Transaction do
  @moduledoc """
  The base transaction for now. There's actually a lot of different
  transaction types.
  """

  # This is the base Transaction. It's not meant to be used, so these
  # are 0 value for now so that we can test these functions.
  @transaction_type 0
  @output_type 0
  @empty_metadata "0x0000000000000000000000000000000000000000"

  @type t :: %__MODULE__{
          inputs: list(Input.t()),
          outputs: list(Output.t()),
          metadata: binary()
        }

  @callback new(map()) :: struct()

  @callback transaction_type() :: non_neg_integer()

  @callback output_type() :: non_neg_integer()

  # @callback decode(binary) :: struct()

  alias __MODULE__
  alias __MODULE__.Input
  alias __MODULE__.Output

  import ExPlasma.Encoding, only: [to_binary: 1]

  defstruct(sigs: [], inputs: [], outputs: [], metadata: nil)

  @doc """
  The associated value for the output type.  This is the base representation
  and is 0 because it does not exist.
  """
  @spec output_type() :: non_neg_integer()
  def output_type(), do: @output_type

  @doc """
  The transaction type value as defined by the contract. This is the base representation
  and is 0 because it does not exist.
  """
  @spec transaction_type() :: non_neg_integer()
  def transaction_type(), do: @transaction_type

  @doc """
  Generate an RLP-encodable list for the transaction.

  ## Examples

  iex> txn = %ExPlasma.Transaction{}
  iex> ExPlasma.Transaction.to_list(txn)
  [0, [], [], <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>]
  """
  @spec to_list(struct()) :: list()
  def to_list(%module{sigs: sigs, inputs: inputs, outputs: outputs, metadata: metadata})
      when is_list(sigs) and length(sigs) > 0 do
    transaction = struct(module, inputs: inputs, outputs: outputs, metadata: metadata)
    [sigs | to_list(transaction)]
  end

  def to_list(%module{inputs: inputs, outputs: outputs, metadata: metadata})
      when is_list(inputs) and is_list(outputs) do
    computed_inputs = Enum.map(inputs, &Input.to_list/1)
    computed_outputs = Enum.map(outputs, fn o -> [module.output_type()] ++ Output.to_list(o) end)
    computed_metadata = metadata || @empty_metadata
    [module.transaction_type(), computed_inputs, computed_outputs, to_binary(computed_metadata)]
  end

  @doc """
  Encodes a transaction into an RLP encodable list.
  """
  def encode(%{inputs: _inputs, outputs: _outputs, metadata: _metadata} = transaction),
    do: transaction |> Transaction.to_list() |> ExRLP.Encode.encode()
end
