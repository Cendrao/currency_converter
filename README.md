# Currency Converter

This is a Currency Converter exercise for Tiltify's job application. The goal of the application is to build a service that will convert currenct amounts. The user should be able to request a value from one currency to another currency.

### Setup and Running the application

First make sure you have set the `FIXER_API_KEY` environment  variable with a valid [Fixer.io](https://fixer.io) API key.

If you are running with docker first build the docker image with:

```
docker build . -t currency_converter
```

And run the container with:

```
docker run -p 4000:4000 currency_converter mix phx.server
```

The application will be ready for requests at [`localhost:4000`](http://localhost:4000).


### Setup and Running without docker

You can run the application without docker, for downloading and installing
dependencies:

```
mix deps.get
```

And run the application with:

```
mix phx.server
```

### Running test

With docker you can run using:

```
docker run currency_converter mix test
```

And without docker just `mix test`.

### Docs

##### GET - /convert
Converts some amount from a currency to another.

##### Parameters
```markdown
| Field  | Type    | Description                      | Example |
|--------|---------|----------------------------------|---------|
| from   | String  | The currency converted from      | USD     |
| to     | String  | The currency converted to        | BRL     |
| amount | Decimal | The value that will be converted | 1300    |
```

##### Example

```bash
 curl -s "localhost:4000/convert?from=USD&to=BRL&amount=1300" | jq
{
  "amount": 1300,
  "from": "USD",
  "rate": 5.118802,
  "result": 6654.4426,
  "timestamp": 1652281083,
  "to": "BRL"
}
```


### Design
  
#### Application  
Even though it is a tiny, one-endpoint application, I opted to use Phoenix Framework because it would be easier for any extensions if more endpoints were needed. As the specs define just one endpoint that returns JSON, I've created the application without HTML, Ecto, and assets as they could be added later in case the specification change.

I used the suggested service [fixer.io](https://fixer.io/) for real-time currency rates, so I've created a module to hold its HTTP client and manipulate data as required.

#### API Design

I kept the response JSON close to the one returned by Fixer. I did that way because the names looked good for what I needed as I didn't have any complex business logic.

#### Tests

I tried to cover most parts of the Fixer client module with unit tests and also did controller tests to guarantee JSON results and status code from the endpoint.

#### Improvements

All the format and currency validations are relying on Fixer API, there are a few opportunities to improve without the need of calling the API, for example:

- Givin an amount with a comma instead of a point, will fail only in Fixer validations;
- If an invalid currency is received it will also fail in Fixer, we can have a currency list on the application and fail faster without making an API call;

There are a few more improvements that could be done before deploying this application to production:

- Add client authentication to guarantee the source of use (if is another micro-service or really our client which is requesting the application);
- Improve logs and observability;
- Add statistics about user behavior;
