defmodule FoodImageScraper do
  @user_agent "FoodImageScraper/1.0"
  
  def run do
    IO.puts("Enter the URL of the food image page:")
    base_url = IO.gets("") |> String.trim()

    case scrape_images(base_url) do
      {:ok, image_urls} ->
        IO.puts("Found #{length(image_urls)} food images:")
        Enum.each(image_urls, &IO.puts/1)
      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end
  end

  defp scrape_images(base_url) do
    {:ok, response} =
      HTTPoison.get(
        base_url,
        headers: [{"User-Agent", @user_agent}],
        follow_redirect: true
      )

    case response.status_code do
      200 ->
        # Parse the HTML and extract image URLs using Floki or another HTML parsing library
        image_urls = parse_and_extract_image_urls(response.body)
        {:ok, image_urls}

      404 ->
        {:error, "Page not found"}

      _ ->
        {:error, "HTTP request failed with status code #{response.status_code}"}
    end
  end

  defp parse_and_extract_image_urls(html) do
    # Parse the HTML content using Floki
    document = Floki.parse(html)

    # Define a CSS selector to match image elements with 'src' attributes
    image_selector = "img[src]"

    # Use Floki to find all matching elements and extract 'src' attributes
    image_urls =
      Floki.find(document, image_selector)
      |> Enum.map(&Floki.attribute(&1, "src"))

    # Filter and clean the URLs (e.g., remove empty or relative URLs)
    image_urls =
      image_urls
      |> Enum.filter(fn url -> !String.trim(url) |> String.contains?("http") end)

    image_urls
  end
end

FoodImageScraper.run()
