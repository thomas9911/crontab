defmodule Crontab do
  @moduledoc """
  This Library is built to parse & write cron expressions, test them against a
  given date and finde the next execution date.

  In the main module defined are helper functions which work directlyfrom a
  string cron expression.
  """

  @doc """
  Find the next execution date relative to now for a string cron expression.

  ### Examples

      iex> Crontab.get_next_run_date("* * * * *")
      {:ok, ~N[2016-12-23 16:00:00.348751]}

  """
  def get_next_run_date(cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_next_run_date(cron_expression, date)
  end

  @doc """
  Find the next execution date relative to a given date for a string cron
  expression.

  ### Examples

      iex> Crontab.get_next_run_date("* * * * *", ~N[2016-12-17 00:00:00])
      {:ok, ~N[2016-12-17 00:00:00]}

  """
  def get_next_run_date(cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} -> Crontab.CronScheduler.get_next_run_date(cron_format, date)
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the next n execution dates relative to now for a string cron expression.

  ### Examples

      iex> Crontab.get_next_run_dates(3, "* * * * *")
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 16:01:00]},
       {:ok, ~N[2016-12-23 16:02:00]}]

  """
  def get_next_run_dates(n, cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_next_run_dates(n, cron_expression, date)
  end

  @doc """
  Find the next n execution dates relative to a given date for a string cron
  expression.

  ### Examples

      iex> Crontab.get_next_run_dates(3, "* * * * *", ~N[2016-12-17 00:00:00])
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-17 00:01:00]},
       {:ok, ~N[2016-12-17 00:02:00]}]

  """
  def get_next_run_dates(0, _, _), do: []
  def get_next_run_dates(n, cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Crontab.CronScheduler.get_next_run_date(cron_format, date)
        [result | get_next_run_dates(n - 1, cron_expression, Timex.shift(run_date, minutes: 1))]
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the previous execution date relative to now for a string cron expression.

  ### Examples

      iex> Crontab.get_previous_run_date("* * * * *")
      {:ok, ~N[2016-12-23 16:00:00.348751]}

  """
  def get_previous_run_date(cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_previous_run_date(cron_expression, date)
  end

  @doc """
  Find the previous execution date relative to a given date for a string cron
  expression.

  ### Examples

      iex> Crontab.get_previous_run_date("* * * * *", ~N[2016-12-17 00:00:00])
      {:ok, ~N[2016-12-17 00:00:00]}

  """
  def get_previous_run_date(cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} -> Crontab.CronScheduler.get_previous_run_date(cron_format, date)
      error = {:error, _} -> error
    end
  end

  @doc """
  Find the previous n execution dates relative to now for a string cron
  expression.

  ### Examples

      iex> Crontab.get_previous_run_dates(3, "* * * * *")
      [{:ok, ~N[2016-12-23 16:00:00]},
       {:ok, ~N[2016-12-23 15:59:00]},
       {:ok, ~N[2016-12-23 15:58:00]}]

  """
  def get_previous_run_dates(n, cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    get_previous_run_dates(n, cron_expression, date)
  end

  @doc """
  Find the previous n execution dates relative to a given date for a string cron
  expression.

  ### Examples

      iex> Crontab.get_previous_run_dates(3, "* * * * *", ~N[2016-12-17 00:00:00])
      [{:ok, ~N[2016-12-17 00:00:00]},
       {:ok, ~N[2016-12-16 23:59:00]},
       {:ok, ~N[2016-12-16 23:58:00]}]

  """
  def get_previous_run_dates(0, _, _), do: []
  def get_previous_run_dates(n, cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} ->
        result = {:ok, run_date} = Crontab.CronScheduler.get_previous_run_date(cron_format, date)
        [result | get_previous_run_dates(n - 1, cron_expression, Timex.shift(run_date, minutes: -1))]
      error = {:error, _} -> error
    end
  end

  @doc """
  Check if now matches a given string cron expression.

  ### Examples

      iex> Crontab.matches_date("*/2 * * * *")
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *")
      {:ok, false}

  """
  def matches_date(cron_expression) when is_binary(cron_expression) do
    date = DateTime.to_naive(DateTime.utc_now)
    matches_date(cron_expression, date)
  end



  @doc """
  Check if given date matches a given string cron expression.

  ### Examples

      iex> Crontab.matches_date("*/2 * * * *", ~N[2016-12-17 00:02:00])
      {:ok, true}

      iex> Crontab.matches_date("*/7 * * * *", ~N[2016-12-17 00:06:00])
      {:ok, false}

  """
  def matches_date(cron_expression, date) when is_binary(cron_expression) do
    case Crontab.CronFormatParser.parse(cron_expression) do
      {:ok, cron_format} -> {:ok, Crontab.CronDateChecker.matches_date(cron_format, date)}
      error = {:error, _} -> error
    end
  end
end
