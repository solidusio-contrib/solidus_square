let appId;
let locationId;
let orderNumber;
let orderToken;

document.addEventListener('DOMContentLoaded', async function () {
  const checkoutPayload = document.getElementById(
    'square-checkout-payload'
  );
  if (checkoutPayload){
    appId = checkoutPayload.dataset.appId;
    locationId = checkoutPayload.dataset.locationId;
    orderNumber = checkoutPayload.dataset.orderNumber;
    orderToken = checkoutPayload.dataset.orderToken;
  }
})

async function initializeCard(payments) {
  const card = await payments.card();
  await card.attach('#card-container');
  return card;
}
// Call this function to send a payment token, buyer name, and other details
// to the project server code so that a payment can be created with
// Payments API
async function createPayment(token) {
  const body = JSON.stringify({
    source_id: token,
    order_number: orderNumber,
    payment_method_id: document.querySelector('[name="payment[payment_method_id]"]:checked').value
  });
  const paymentResponse = await fetch('/solidus_square/api/payments/square', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      "X-Spree-Order-Token": orderToken
    },
    body,
  });
  const paymentStatusDiv = document.getElementById('payment-status-container');
  if (paymentResponse.ok) {
    document.getElementById("card-container").remove()
    document.getElementById("square-card-button").remove()
    paymentStatusDiv.innerHTML = "Payment Successfully"
    return paymentResponse.json();
  } else {
    paymentStatusDiv.innerHTML = "Payment Failed"
    const errorBody = await paymentResponse.text();
    throw new Error(errorBody);
  }
}

// This function tokenizes a payment method.
// The error thrown from this async function denotes a failed tokenization,
// which is due to buyer error (such as an expired card). It is up to the
// developer to handle the error and provide the buyer the chance to fix
// their mistakes.
async function tokenize(paymentMethod) {
  const tokenResult = await paymentMethod.tokenize();
  if (tokenResult.status === 'OK') {
    return tokenResult.token;
  } else {
    let errorMessage = `Tokenization failed-status: ${tokenResult.status}`;
    if (tokenResult.errors) {
      errorMessage += ` and errors: ${JSON.stringify(
        tokenResult.errors
      )}`;
    }
    throw new Error(errorMessage);
  }
}

// Helper method for displaying the Payment Status on the screen.
// status is either SUCCESS or FAILURE;
function displayPaymentResults(status) {
  const statusContainer = document.getElementById(
    'payment-status-container'
  );
  if (status === 'SUCCESS') {
    statusContainer.classList.remove('is-failure');
    statusContainer.classList.add('is-success');
  } else {
    statusContainer.classList.remove('is-success');
    statusContainer.classList.add('is-failure');

  }

  statusContainer.style.visibility = 'visible';
}

document.addEventListener('DOMContentLoaded', async function () {
  if (!window.Square) {
    return;
  }
  const payments = window.Square.payments(appId, locationId);
  let card;
  try {
    card = await initializeCard(payments);
  } catch (e) {
    console.error('Initializing Card failed', e);
    return;
  }

  async function handlePaymentMethodSubmission(event, paymentMethod) {
    event.preventDefault();

    try {
      // disable the submit button as we await tokenization and make a
      // payment request.

      cardButton.disabled = true;
      const token = await tokenize(paymentMethod);
      const paymentResults = await createPayment(token);
      displayPaymentResults('SUCCESS');

      console.debug('Payment Success', paymentResults);
    } catch (e) {
      cardButton.disabled = false;
      displayPaymentResults('FAILURE');
      console.error(e.message);
    }
  }

  const cardButton = document.getElementById(
    'square-card-button'
  );
  cardButton.addEventListener('click', async function (event) {

    await handlePaymentMethodSubmission(event, card);
  });
});
