type Kind =
  | "SlideFromLeft"
  | "SlideFromTop"
  | "SlideFromRight"
  | "SlideFromBottom"
  | "Fade";
class AnimatorFrom extends HTMLElement {
  constructor() {
    super();
  }
}

const observerConfig = { attributes: true, childList: true, subtree: true };
class Animator extends HTMLElement {
  observer: MutationObserver;

  constructor() {
    super();
    this.observer = new MutationObserver(this.mutationHandler.bind(this));
  }

  connectedCallback() {
    this.observer.observe(this, observerConfig);
  }

  mutationHandler(mutationList: MutationRecord[], observer: MutationObserver) {
    console.log("mutationHandler");
    const removedNodes = mutationList.flatMap(element => {
      return Array.from(element.removedNodes);
    });
    console.log(removedNodes);
    observer.disconnect();
    this.transitioning(removedNodes);
  }

  getContent(): HTMLElement {
    return this.getElementsByTagName("elm-animator-content")[0] as HTMLElement;
  }

  transitioning(fromContent: Node[]) {
    const kind: Kind = this.getAttribute("elm-animator-kind") as Kind;

    const from = new AnimatorFrom();
    const to = this.getContent();

    fromContent.forEach(node => from.appendChild(node));
    this.appendChild(from);

    from.style.gridArea = "content";
    to.style.gridArea = "content";

    switch (kind) {
      case "SlideFromLeft":
        this.slideInFromLeft(from, to);
        break;

      case "SlideFromRight":
        this.slideInFromRight(from, to);
        break;

      case "SlideFromTop":
        this.slideInFromTop(from, to);
        break;

      case "SlideFromBottom":
        this.slideInFromBottom(from, to);
        break;

      case "Fade":
        this.fade(from, to);
        break;

      default:
        break;
    }
  }

  slide(
    from: HTMLElement,
    to: HTMLElement,
    fromAnimation: Keyframe[],
    toAnimation: Keyframe[]
  ) {
    const duration = 500;
    const options: KeyframeAnimationOptions = {
      duration,
      iterations: 1,
      fill: "forwards",
      easing: "ease-in-out"
    };

    from.animate(fromAnimation, options);
    to.animate(toAnimation, options).addEventListener("finish", () => {
      this.removeChild(from);
      this.dispatchEvent(new Event("elmAnimatorFinish"));
      this.observer.observe(this, observerConfig);
    });
  }

  slideInFromRight(from: HTMLElement, to: HTMLElement) {
    this.slide(
      from,
      to,
      [{ transform: "translateX(0%)" }, { transform: "translateX(-100%)" }],
      [{ transform: "translateX(100%)" }, { transform: "translateX(0%)" }]
    );
  }

  slideInFromLeft(from: HTMLElement, to: HTMLElement) {
    this.slide(
      from,
      to,
      [{ transform: "translateX(0%)" }, { transform: "translateX(100%)" }],
      [{ transform: "translateX(-100%)" }, { transform: "translateX(0%)" }]
    );
  }

  slideInFromTop(from: HTMLElement, to: HTMLElement) {
    this.slide(
      from,
      to,
      [{ transform: "translateY(0%)" }, { transform: "translateY(100%)" }],
      [{ transform: "translateY(-100%)" }, { transform: "translateY(0%)" }]
    );
  }

  slideInFromBottom(from: HTMLElement, to: HTMLElement) {
    this.slide(
      from,
      to,
      [{ transform: "translateY(0%)" }, { transform: "translateY(-100%)" }],
      [{ transform: "translateY(100%)" }, { transform: "translateY(0%)" }]
    );
  }

  fade(from: HTMLElement, to: HTMLElement) {
    const duration = 500;
    const options: KeyframeAnimationOptions = {
      duration,
      iterations: 1,
      fill: "forwards",
      easing: "ease-in-out"
    };

    from.animate([{ opacity: "1" }, { opacity: "0" }], options);
    to.animate([{ opacity: "0" }, { opacity: "1" }], options).addEventListener(
      "finish",
      () => {
        this.removeChild(from);
        this.dispatchEvent(new Event("elmAnimatorFinish"));
        this.observer.observe(this, observerConfig);
      }
    );
  }
}

document.addEventListener("DOMContentLoaded", function() {
  customElements.define("elm-animator", Animator);
  customElements.define("elm-animator-from", AnimatorFrom);
});
