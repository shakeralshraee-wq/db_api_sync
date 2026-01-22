const jsonServer = require('json-server');
const auth = require('json-server-auth');

const app = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// Bind the router db to the app
app.db = router.db;

app.use(middlewares);
app.use(jsonServer.bodyParser);

// Bind the auth middleware before the router
app.use(auth);
app.use(router);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`JSON Server (with auth) is running on port ${PORT}`);
});
