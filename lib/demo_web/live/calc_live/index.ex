defmodule DemoWeb.CalcLive.Index do
  use Phoenix.LiveView
  alias DemoWeb.CalcView

  def mount(_session, socket) do
    {:ok, reset_state(socket)}
  end

  def render(assigns), do: CalcView.render("index.html", assigns)

  # Digit clicks
  def handle_event("digit", digit, socket) do
    update_display(digit, socket)
  end

  # Number key presses
  def handle_event("keypress", key, socket) when (key >= "0" and key <= "9") or key == "." do
    update_display(key, socket )
  end
  def handle_event("keypress", key, socket) when key in ["+","-","/","*"] do
    handle_event("operator", key, socket)
  end
  def handle_event("keypress", key, socket) when key == "=" do
    handle_event("solve", key, socket)
  end
  def handle_event("keypress", _key, socket), do: {:noreply, socket}

  # Operator clicks (+,-,*,/):
  # when there is no pending operator. Whatever is on the display becomes the current value.
  def handle_event("operator", operator, socket = %{assigns: %{pending_operator: ''}}) do
    {:noreply, assign(socket, pending_operator: operator, clear_display_on_next_digit: true, value: socket.assigns.display )}
  end

  # when there is a pending operator. Whatever is on the display combines with the current value to set a new value.
  # Perform the pending operation and this new operator becomes the pending operator.
  def handle_event("operator", operator, socket) do
    {:ok, new_value} = peform_pending_operation(socket)
    {:noreply, assign(socket, pending_operator: operator, clear_display_on_next_digit: true, value: new_value, display: new_value )}
  end

  # Equal sign clicked
  # Perform pending operation and clear the pending operator.
  def handle_event("solve", _, socket) do
    {:ok, new_value} = peform_pending_operation(socket)
    {:noreply, assign(socket, pending_operator: '', clear_display_on_next_digit: true, value: new_value, display: new_value )}
  end

  # Utility buttons
  def handle_event("square_root", _, socket) do
    {:noreply, assign(socket, display: :math.sqrt(display_to_float(socket)))}
  end

  def handle_event("posneg", _, socket) do
    {:noreply, assign(socket, display: display_to_float(socket) * -1)}
  end

  def handle_event("reset", _, socket) do
    {:noreply, reset_state(socket, socket.assigns.memory)}
  end

  # Memory events
  def handle_event("memory", "clear", socket) do
    update_memory(socket, 0)
  end

  def handle_event("memory", "store", socket) do
    update_memory(socket, display_to_float(socket))
  end

  def handle_event("memory", "add", socket) do
    update_memory(socket, socket.assigns.memory + display_to_float(socket))
  end

  def handle_event("memory", "minus", socket) do
    update_memory(socket, socket.assigns.memory - display_to_float(socket))
  end

  def handle_event("memory", "recall", socket) do
    {:noreply, assign(socket, display: socket.assigns.memory, clear_display_on_next_digit: true )}
  end

  # Private
  defp display_to_float(socket) do
    {display, _} = Float.parse("#{socket.assigns.display}")
    display
  end

  defp reset_state(socket, memory \\ 0) do
    assign(socket, %{display: '0', value: 0, pending_operator: '',
      clear_display_on_next_digit: true, memory: memory, key: ''})
  end

  defp peform_pending_operation(socket) do
    {accumulator, _} = Float.parse("#{socket.assigns.value}")
    {:ok, _new_value} = Abacus.eval("#{accumulator} #{socket.assigns.pending_operator} #{display_to_float(socket)}")
  end

  defp update_display(digit, socket = %{assigns: %{clear_display_on_next_digit: true}} ) do
    {:noreply, assign(socket, display: digit, clear_display_on_next_digit: false)}
  end
  defp update_display(digit, socket ) do
    {:noreply, assign(socket, display: "#{socket.assigns.display}#{digit}")}
  end

  defp update_memory(socket, new_memory) do
    {:noreply, assign(socket, memory: new_memory, clear_display_on_next_digit: true )}
  end
end
