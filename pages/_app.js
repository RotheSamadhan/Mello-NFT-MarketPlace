import "../styles/globals.css";

//INTRNAL IMPORT
import { Navbar } from "../components/compoindex.js";

const MyApp = ({ Component, pageProps }) => (
  <div>
    <Navbar />
    <Component {...pageProps} />
  </div>
);

export default MyApp;
