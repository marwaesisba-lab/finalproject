import nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "ma.yahiaoui@esi-sba.dz",
    pass: "difd jlgo subl zppm"
  },
});
