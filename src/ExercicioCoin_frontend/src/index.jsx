import { Link } from 'react-router-dom';
import { createActor } from 'declarations/InternetIdentity';
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { BrowserRouter as Router, Route, Routes, useNavigate } from 'react-router-dom';

let actorInternetIdentity = null;

function Index({ onLoginSuccess }) {

    const navigate = useNavigate();

    async function login() {

        // Criar o authClient
        let authClient = await AuthClient.create();

        // Inicia o processo de login e aguarda até que ele termine
        await authClient.login({
            // Redireciona para o provedor de identidade da ICP (Internet Identity)
            identityProvider: "https://identity.ic0.app/#authorize",
            onSuccess: async () => {
                // Caso entrar neste bloco significa que a autenticação ocorreu com sucesso!
                const identity = authClient.getIdentity();
                console.log(identity.getPrincipal().toText()); // Já é possivel ter acesso ao Principal do usuário atenticado         

                /* A identidade do usuário autenticado poderá ser utilizada para criar um HttpAgent.
                   Ele será posteriormente utilizado para criar o Actor (autenticado) correspondente ao Canister de Backend  */
                const agent = new HttpAgent({ identity });

                /* O comando abaixo irá criar um Actor Actor (autenticado) correspondente ao Canister de Backend  
                  desta forma, todas as chamadas realizadas a metodos SHARED no Backend irão receber o "Principal" do usuário */
                actorInternetIdentity = createActor(process.env.CANISTER_ID_InternetIdentity, {
                    agent,
                });

                //document.getElementById("principalText").innerText = principalText; este campo não existe
                //O principal anônimo no Internet Computer é representado pelo valor textual "2vxsx-fae".   
                onLoginSuccess(); // atualiza estado do App

                navigate('/tarefas');

            },

            windowOpenerFeatures: `
                                left=${window.screen.width / 2 - 525 / 2},
                                top=${window.screen.height / 2 - 705 / 2},
                                toolbar=0,location=0,menubar=0,width=525,height=705
                              `,
        })
    }

    return (
        <main style={{ padding: '2rem', textAlign: 'center' }}>
            <h1>Exercicio Coin</h1>
            <p>Autentique-se com Internet Identity para acessar sua conta.</p>

            <button
                onClick={login}
            >
                Internet Identity
            </button>
        </main>
    );
}

export default Index;