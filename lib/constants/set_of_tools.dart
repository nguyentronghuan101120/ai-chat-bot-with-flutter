import 'package:dart_openai/dart_openai.dart';

enum SetOfTools {
  generateImage,
  getWeather,
  getStockPrice,
  getStockSymbol,
  readWebPage,
}

extension SetOfToolsExtension on SetOfTools {
  OpenAIToolModel get tool {
    return OpenAIToolModel(
      type: "function",
      function: _getFunction(),
    );
  }

  OpenAIFunctionModel _getFunction() {
    return switch (this) {
      SetOfTools.generateImage => OpenAIFunctionModel.withParameters(
          name: name,
          parameters: [
            OpenAIFunctionProperty.string(
              name: "prompt",
              description:
                  "The prompt used for generate the image (must be in English)",
            ),
          ],
        ),
      SetOfTools.getWeather => OpenAIFunctionModel.withParameters(
          name: name,
          parameters: [
            OpenAIFunctionProperty.string(
              name: "location",
              description: "The city name or address to get weather data for",
              isRequired: false,
            ),
            OpenAIFunctionProperty.number(
              name: "latitude",
              description: "The latitude coordinate for the location",
              isRequired: false,
            ),
            OpenAIFunctionProperty.number(
              name: "longitude",
              description: "The longitude coordinate for the location",
              isRequired: false,
            ),
            OpenAIFunctionProperty.string(
              name: "units",
              description:
                  "Temperature unit system to use (metric, imperial, or standard)",
              enumValues: ["metric", "imperial", "standard"],
              isRequired: false,
            ),
            OpenAIFunctionProperty.integer(
              name: "forecastDays",
              description: "Number of days to include in the forecast",
              isRequired: false,
            ),
          ],
        ),
      SetOfTools.getStockPrice => OpenAIFunctionModel.withParameters(
          name: name,
          parameters: [
            OpenAIFunctionProperty.string(
              name: "symbol",
              description:
                  "The stock symbol/ticker to get the price for (e.g., AAPL, MSFT, GOOGL)",
              isRequired: true,
            ),
          ],
        ),
      SetOfTools.getStockSymbol => OpenAIFunctionModel.withParameters(
          name: name,
          parameters: [
            OpenAIFunctionProperty.string(
              name: "companyName",
              description:
                  "The name of the company to find the stock symbol for (e.g., Apple, Microsoft, Google)",
              isRequired: true,
            ),
          ],
        ),
      SetOfTools.readWebPage => OpenAIFunctionModel.withParameters(
          name: name,
          parameters: [
            OpenAIFunctionProperty.string(
              name: "url",
              description:
                  "The URL of the web page to read and extract content from",
              isRequired: true,
            ),
          ],
        ),
    };
  }
}
