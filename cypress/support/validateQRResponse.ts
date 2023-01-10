import { StaticResponse } from "cypress/types/net-stubbing";

// use a type predicate to let typescript know that
// the body is an ArrayBuffer. This is needed so that TS
// knows that body.byteLength is a valid property.
function isArrayBuffer(obj: Object): obj is ArrayBuffer {
  return obj.constructor.name === "ArrayBuffer";
}

export function validateQRResponse(
  qrResponse: StaticResponse,
  expectedFilename: string
) {
  const { body, headers } = qrResponse;

  if (!isArrayBuffer(body)) {
    throw new Error("body is not an ArrayBuffer");
  }

  // check that the server response is not null
  expect(body.byteLength).to.be.greaterThan(100);

  // and that it's a png image
  expect(headers["content-type"]).to.equal("image/png");

  // and that the filename will be z-cla.png
  expect(headers["content-disposition"]).to.match(
    new RegExp(`filename=\"${expectedFilename}\"`)
  );
}
